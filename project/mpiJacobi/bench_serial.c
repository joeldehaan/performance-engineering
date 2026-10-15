#include "basic.h"

void solver(double *, double *, int, int, double, int);

int main()
{
    double *v;
    double *f;

    v = grid_alloc(NX, NY);
    f = grid_alloc(NX, NY);

    // Initialise input: f = sin(x+y), v = 0
    init_problem(v, f, NX, NY, 0);

    solver(v, f, NX, NY, EPS, NMAX);

    // for (int iy = 0; iy < NY; iy++)
    //     for (int ix = 0; ix < NX; ix++)
    //         printf("%d,%d,%e\n", ix, iy, v[iy*NX+ix]);

    // Clean-up
    free(v);
    free(f);
}
void solver(double *v, double *f, int nx, int ny, double eps, int nmax)
{
    int n = 0;
    double e = 2. * eps;
    double *vp;

    vp = (double *)malloc(nx * ny * sizeof(double));

    while ((e > eps) && (n < nmax))
    {
        e = 0.0;

        for (int ix = 1; ix < (nx - 1); ix++)
        {
            for (int iy = 1; iy < (ny - 1); iy++)
            {
                double d;

                vp[iy * nx + ix] = -0.25 * (f[iy * nx + ix] -
                                            (v[nx * iy + ix + 1] + v[nx * iy + ix - 1] +
                                             v[nx * (iy + 1) + ix] + v[nx * (iy - 1) + ix]));

                d = fabs(vp[nx * iy + ix] - v[nx * iy + ix]);
                e = (d > e) ? d : e;
            }
        }

        // Update v and compute error as well as error weight factor

        double w = 0.0;

        for (int ix = 1; ix < (nx - 1); ix++)
        {
            for (int iy = 1; iy < (ny - 1); iy++)
            {
                v[nx * iy + ix] = vp[nx * iy + ix];
                w += fabs(v[nx * iy + ix]);
            }
        }

        for (int ix = 1; ix < (nx - 1); ix++)
        {
            v[nx * 0 + ix] = v[nx * (ny - 2) + ix];
            v[nx * (ny - 1) + ix] = v[nx * 1 + ix];
            w += fabs(v[nx * 0 + ix]) + fabs(v[nx * (ny - 1) + ix]);
        }

        for (int iy = 1; iy < (ny - 1); iy++)
        {
            v[nx * iy + 0] = v[nx * iy + (nx - 2)];
            v[nx * iy + (nx - 1)] = v[nx * iy + 1];
            w += fabs(v[nx * iy + 0]) + fabs(v[nx * iy + (nx - 1)]);
        }

        w /= (nx * ny);
        e /= w;

        // if ((n % 10) == 0)
        //     printf("%5d, %0.4e\n", n, e);

        n++;
    }

    free(vp);

    if (e < eps)
        printf("Converged after %d iterations (nx=%d, ny=%d, e=%.2e)\n", n, nx, ny, e);
    else
        printf("ERROR: Failed to converge\n");
}
