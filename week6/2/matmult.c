#include <stdio.h>
#include <stdlib.h>

void mxv(double *restrict y,
         double const *restrict a,
         double const *restrict x,
         int m, int n)
{
#pragma omp parallel shared(a, x, y)

#pragma omp for schedule(static)
    for (int i = 0; i < m; i++)
    {
        double sum = 0.0;
        for (int j = 0; j < n; j++)
            sum += a[i * n + j] * x[j];

        y[i] = sum;
    }
}

#ifndef N
#define N 100 // matrix/vector size
#endif

int main()
{
    double *mat = (double *)malloc(N * N * sizeof(double));
    double *vec = (double *)malloc(N * sizeof(double));

    for (size_t idx = 0; idx < N * N; ++idx)
        mat[idx] = (rand() / RAND_MAX * 100);

    double *dest = (double *)malloc(N * sizeof(double));

    mxv(dest, mat, vec, N, N);
}