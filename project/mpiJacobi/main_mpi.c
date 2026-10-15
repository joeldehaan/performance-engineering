#include <mpi.h>
#include "basic.h"

void solver(double *, double *, int, int, double, int);

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

    printf("time: %d", t1 - t2);

    free(v);
    free(f);
    MPI_Finalize();
}
