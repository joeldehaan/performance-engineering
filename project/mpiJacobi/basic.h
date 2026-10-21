#ifndef BASIC_MPI_JACOBI
#define BASIC_MPI_JACOBI

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifndef NX
#define NX 1024
#endif
#ifndef NY
#define NY 16
#endif
/* guarded so that the benchmark script can set them with -DNMAX=... -DEPS=... */
#ifndef NMAX
#define NMAX 200000
#endif
#ifndef EPS
#define EPS 1e-5
#endif

/* static inline: a plain function in a header would be defined in every .c file
 * that includes it (duplicate symbol at link time) */
static inline size_t IDX(size_t ix, size_t iy, size_t nx)
{ // to acess components of the grid
    return (iy * nx + ix);
}

static inline double *grid_alloc(size_t nx, size_t rows)
{
    double *g = (double *)malloc(nx * rows * sizeof(double));
    if (!g) // no inisialisation
    {
        fprintf(stderr, "out of memory\n");
        exit(1);
    }
    return g;
}

static inline void decompose(int interior, int rank, int size, int *ly, int *first)
{
    int base = interior / size, rem = interior % size;
    *ly = base + (rank < rem ? 1 : 0);
    *first = rank * base + (rank < rem ? rank : rem);
}

static inline void ghost_cols_local(double *v, int nx, int r0, int r1)
{
    for (int iy = r0; iy <= r1; iy++)
    {
        v[nx * iy + 0] = v[nx * iy + (nx - 2)];
        v[nx * iy + (nx - 1)] = v[nx * iy + 1];
    }
}

// Periodic copy of top/bottom ghost rows for one process
static inline void ghost_rows_local(double *v, int nx, int ny)
{
    for (int ix = 1; ix < nx - 1; ix++)
    {
        v[nx * 0 + ix] = v[nx * (ny - 2) + ix];
        v[nx * (ny - 1) + ix] = v[nx * 1 + ix];
    }
}

/* Problem preparation
 *   f : sin(x + y)
 *   v : 0*/
static inline void init_problem(double *v, double *f, int nx, int rows, int first)
{

    for (int l = 0; l < rows; l++)
        for (int ix = 0; ix < nx; ix++)
        {
            const double x = 2.0 * ix / (NX - 1.0) - 1.0;
            const double y = 2.0 * (first + l) / (NY - 1.0) - 1.0;
            f[nx * l + ix] = sin(x + y);
            v[IDX(ix, l, nx)] = 0.0;
        }
}

#endif
