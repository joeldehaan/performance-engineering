#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <utility>
#include <array>
#include <print>
#include <memory>

using namespace std;

template <size_t nx, size_t ny>
bool solver(array<array<double, nx>, ny> &v, array<array<double, nx>, ny> const &f, double const eps, size_t const maxIter)
{
    auto vpOwner = make_unique<array<array<double, nx>, ny>>();

    array<array<double, nx>, ny> &vp = *vpOwner;

    for (size_t iter = 0; iter < maxIter; ++iter)
    {
        double e = 0.0;

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++ )
            {
                double d;

                vp[iy][ix] = -0.25 * (f[iy][ix] -
                    (v[iy][ix+1] + v[iy][ix-1] +
                     v[iy+1][ix] + v[iy-1][ix]));

                d = fabs(vp[iy][ix] - v[iy][ix]);

                e = (d > e) ? d : e;
            }
        }

        // Update v and compute error as well as error weight factor

        double w = 0.0;


        swap(v, vp); // identical since vp is immediately written to next loop cycle

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++)
            {
                w += fabs(v[iy][ix]);
            }
        }

        for (size_t ix = 1; ix < (nx-1); ix++)
        {
            v[0][ix] = v[ny-2][ix];
            v[ny-1][ix] = v[1][ix];
            w += fabs(v[0][ix]) + fabs(v[ny-1][ix]);
        }

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            v[iy][0]      = v[iy][nx-2];
            v[iy][nx-1] = v[iy][1];
            w += fabs(v[iy][0]) + fabs(v[iy][nx-1]);
        }

        w /= (nx * ny);
        e /= w;

        if (e < eps)
        {
            println("Converged after {} iterations (nx={}, ny={}, e={})", iter, nx, ny, e);
            return true;
        }
    }

    println("ERROR: Failed to converge");
    return false;

}

#ifndef NX
#define NX 512
#endif
#ifndef NY
#define NY 512
#endif
#define NMAX 200000
#define EPS 1e-5

int main()
{
    auto vOwner = make_unique<array<array<double, NX>, NY>>();
    auto fOwner = make_unique<array<array<double, NX>, NY>>();
    array<array<double, NX>, NY> &v = *vOwner;
    array<array<double, NX>, NY> &f = *fOwner;

    // Initialise input
    for (size_t iy = 0; iy < NY; iy++)
    {
        for (size_t ix = 0; ix < NX; ix++)
        {
            v[iy][ix] = 0.0;

            double const x = 2.0 * ix / (NX - 1.0) - 1.0;
            double const y = 2.0 * iy / (NY - 1.0) - 1.0;
            f[iy][ix] = sin(x + y);
        }
    }

    solver(v, f, EPS, NMAX);
}
