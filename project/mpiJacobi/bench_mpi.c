/*
 *   1. update halo
 *   2. synchronisation
 *   3. compute
 *   4. synchronisation
 */
#include <mpi.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#include "basic.h"

void solver(double *v, double *f, int nx, int ny, double eps, int nmax)
{
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    size_t const ly = ny - 2;                   /* own interior rows */
    size_t const up = (rank - 1 + size) % size; /* periodic neighbours */
    size_t const down = (rank + 1) % size;

    int ny_glob;
    MPI_Allreduce(&ly, &ny_glob, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    ny_glob += 2;

    double *vp = (double *)malloc((size_t)nx * ny * sizeof(double));
    int n = 0;
    double e = 2. * eps;

    while ((e > eps) && (n < nmax))
    {
        // 1. update halo
        ghost_cols_local(v, nx, 1, ly);
        /* my first row -> upper neighbour, my bottom halo <- lower neighbour    */
        MPI_Sendrecv(&v[IDX(0, 1, nx)], nx, MPI_DOUBLE, up, 0,
                     &v[IDX(0, ly + 1, nx)], nx, MPI_DOUBLE, down, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        /* my last row -> lower neighbour, my top halo <- upper neighbour        */
        MPI_Sendrecv(&v[IDX(0, ly, nx)], nx, MPI_DOUBLE, down, 1,
                     &v[IDX(0, 0, nx)], nx, MPI_DOUBLE, up, 1,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        //  2. synchronisation - wait
        MPI_Barrier(MPI_COMM_WORLD);

        // compute
        double e_loc = 0.0;
        for (size_t iy = 1; iy <= ly; iy++)
            for (size_t ix = 1; ix < (nx - 1); ix++)
            {
                vp[iy * nx + ix] = -0.25 * (f[iy * nx + ix] -
                                            (v[nx * iy + ix + 1] + v[nx * iy + ix - 1] +
                                             v[nx * (iy + 1) + ix] + v[nx * (iy - 1) + ix]));
                double d = fabs(vp[nx * iy + ix] - v[nx * iy + ix]);
                e_loc = (d > e_loc) ? d : e_loc;
            }

        double w_loc = 0.0;
        for (size_t iy = 1; iy <= ly; ++iy)
        {
            for (size_t ix = 1; ix < (nx - 1); ++ix)
            {
                v[nx * iy + ix] = vp[nx * iy + ix];
                w_loc += fabs(v[nx * iy + ix]);
            }
            w_loc += fabs(v[nx * iy + 1]) + fabs(v[nx * iy + (nx - 2)]); /* ghost cols */
        } // same for loops as before

        for (int ix = 1; ix < (nx - 1); ix++)
        {
            if (rank == size - 1)
                w_loc += fabs(v[nx * ly + ix]); /* top ghost row    = last row  */
            if (rank == 0)
                w_loc += fabs(v[nx * 1 + ix]); /* bottom ghost row = first row */
        }

        //  synchronisation
        double w; // add all errors and weight
        MPI_Allreduce(&e_loc, &e, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
        MPI_Allreduce(&w_loc, &w, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);

        w /= (nx * ny_glob);
        e /= w;
        n++;
    }

    free(vp);

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

    int ly, first;
    decompose(NY - 2, rank, size, &ly, &first);

    double *v = grid_alloc(NX, ly + 2);
    double *f = grid_alloc(NX, ly + 2);
    init_problem(v, f, NX, ly + 2, first); // f = sin(x+y)

    double t0 = MPI_Wtime();
    solver(v, f, NX, ly + 2, EPS, NMAX);
    double t1 = MPI_Wtime();

    printf("time: %f \n", t1 - t0);

    free(v);
    free(f);
    MPI_Finalize();
}
