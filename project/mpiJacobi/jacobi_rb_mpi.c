/*
 * MPI red-black (checkerboard) Jacobi solver, packed layout.
 * Same skeleton as the MPI Jacobi solver:
 *   1. update halo
 *   2. synchronisation
 *   3. compute   (red-black sweep, same maths as the sequential red-black code)
 *   4. synchronisation (reduce)
 *
 * Storage: for every colour c a packed plane of (ly+2) rows x (nx/2) entries,
 *   plane[c][l*hx + ix/2]  holds grid point (ix, global row first+l) with
 *   colour (ix + first + l) % 2.
 * Requirements: nx even, global ny even (periodic ghost rows must have the same
 * column parity as their source rows), every rank owns at least one row.
 */
#include <mpi.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#include "basic.h"

enum { RED = 0, BLACK = 1 };

/* parity of the full-grid column of the first packed entry of `color` in global row `grow` */
static inline int col_parity(int color, size_t grow) { return (int)((color + grow) % 2); }

/* grid -> two packed colour planes (local row l is global row first + l) */
static void pack(const double *g, double *p[2], int nx, int rows, size_t first)
{
    const int hx = nx / 2;
    for (int l = 0; l < rows; l++)
        for (int ix = 0; ix < nx; ix++)
            p[(ix + first + l) % 2][(size_t)l * hx + ix / 2] = g[(size_t)l * nx + ix];
}

static void unpack(double *g, double *const p[2], int nx, int rows, size_t first)
{
    const int hx = nx / 2;
    for (int l = 0; l < rows; l++)
        for (int ix = 0; ix < nx; ix++)
            g[(size_t)l * nx + ix] = p[(ix + first + l) % 2][(size_t)l * hx + ix / 2];
}

/* value of grid point (ix, local row l) read from packed planes */
static inline double at(double *const p[2], int hx, int l, size_t first, int ix)
{
    return p[(ix + first + l) % 2][(size_t)l * hx + ix / 2];
}

/* first = global index of local row 0 (needed for the colour of a point) */
void solver(double *v, double *f, int nx, int ny, int first, double eps, int nmax)
{
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    const int ly = ny - 2;                  /* own interior rows */
    const int up = (rank - 1 + size) % size; /* periodic neighbours */
    const int down = (rank + 1) % size;
    const int hx = nx / 2;                  /* packed row length */
    const size_t plane = (size_t)ny * hx;

    int ny_glob;
    MPI_Allreduce(&ly, &ny_glob, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    ny_glob += 2;

    double *buf = (double *)malloc(6 * plane * sizeof(double));
    double *cur[2] = {buf, buf + plane};
    double *nxt[2] = {buf + 2 * plane, buf + 3 * plane};
    double *rhs[2] = {buf + 4 * plane, buf + 5 * plane};
    pack(v, cur, nx, ny, first);
    pack(f, rhs, nx, ny, first);

    int n = 0;
    double e = 2. * eps;

    while ((e > eps) && (n < nmax))
    {
        // 1. update halo
        for (int c = 0; c < 2; c++)
        {
            /* periodic ghost columns (local, packed) */
            for (int l = 1; l <= ly; l++)
            {
                double *row = cur[c] + (size_t)l * hx;
                if (col_parity(c, first + l) == 0)
                    row[0] = row[hx - 1];
                else
                    row[hx - 1] = row[0];
            }
            /* my first row -> upper neighbour, my bottom halo <- lower neighbour */
            MPI_Sendrecv(cur[c] + (size_t)1 * hx, hx, MPI_DOUBLE, up, 2 * c,
                         cur[c] + (size_t)(ly + 1) * hx, hx, MPI_DOUBLE, down, 2 * c,
                         MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            /* my last row -> lower neighbour, my top halo <- upper neighbour */
            MPI_Sendrecv(cur[c] + (size_t)ly * hx, hx, MPI_DOUBLE, down, 2 * c + 1,
                         cur[c] + (size_t)0 * hx, hx, MPI_DOUBLE, up, 2 * c + 1,
                         MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        //  2. synchronisation - wait
        MPI_Barrier(MPI_COMM_WORLD);

        // 3. compute (identical to the sequential red-black sweep, scalar version)
        double e_loc = 0.0; /* max |change| */
        double w_loc = 0.0; /* sum |new value| over interior points */
        for (int l = 1; l <= ly; l++)
        {
            for (int c = RED; c <= BLACK; c++)
            {
                const int o = 1 - c;                              /* opposite colour */
                const int start = 1 - col_parity(c, first + l);   /* first interior packed entry */
                double *out = nxt[c] + (size_t)l * hx;
                const double *old = cur[c] + (size_t)l * hx;
                const double *rh = rhs[c] + (size_t)l * hx;
                const double *side = cur[o] + (size_t)l * hx;
                const double *above = cur[o] + (size_t)(l - 1) * hx;
                const double *below = cur[o] + (size_t)(l + 1) * hx;

                for (int k = 0; k < hx - 1; k++)
                {
                    const int i = start + k;
                    const double u = 0.25 * ((side[k] + side[k + 1]) + (above[i] + below[i]) - rh[i]);
                    out[i] = u;
                    const double d = fabs(u - old[i]);
                    e_loc = (d > e_loc) ? d : e_loc;
                    w_loc += fabs(u);
                }
            }
        }

        /* weight: periodic ghost columns of my rows (= images of columns nx-2 and 1) ... */
        for (int l = 1; l <= ly; l++)
            w_loc += fabs(at(nxt, hx, l, first, nx - 2)) + fabs(at(nxt, hx, l, first, 1));
        /* ... and periodic ghost rows (only counted once globally) */
        for (int ix = 1; ix < (nx - 1); ix++)
        {
            if (rank == size - 1)
                w_loc += fabs(at(nxt, hx, ly, first, ix)); /* top ghost row    = last row  */
            if (rank == 0)
                w_loc += fabs(at(nxt, hx, 1, first, ix));  /* bottom ghost row = first row */
        }

        /* new field becomes current field (replaces the copy vp -> v) */
        for (int c = 0; c < 2; c++)
        {
            double *t = cur[c];
            cur[c] = nxt[c];
            nxt[c] = t;
        }

        //  4. synchronisation
        double w; // add all errors and weight
        MPI_Allreduce(&e_loc, &e, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
        MPI_Allreduce(&w_loc, &w, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);

        w /= ((double)nx * ny_glob);
        e /= w;
        n++;
    }

    unpack(v, cur, nx, ny, first); /* hand the solution back in the plain layout */
    free(buf);

    if (rank == 0)
    {
        if (e < eps)
            printf("Converged after %d iterations (nx=%d, ny=%d, e=%.2e)\n", n, nx, ny_glob, e);
        else
            printf("ERROR: Failed to converge\n");
    }
}

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if ((NX % 2) || (NY % 2))
    {
        if (rank == 0)
            fprintf(stderr, "red-black split needs even NX and NY\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    int ly, first;
    decompose(NY - 2, rank, size, &ly, &first);

    double *v = grid_alloc(NX, ly + 2);
    double *f = grid_alloc(NX, ly + 2);
    init_problem(v, f, NX, ly + 2, first); // f = sin(x+y)

    double t0 = MPI_Wtime();
    solver(v, f, NX, ly + 2, first, EPS, NMAX);
    double t1 = MPI_Wtime();

    printf("time: %f \n", t1 - t0);

    free(v);
    free(f);
    MPI_Finalize();
}
