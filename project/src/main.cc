
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifndef NX
#define NX 1024
#endif
#ifndef NY
#define NY 16
#endif
#define NMAX 200000
#define EPS 1e-5

#include <array>

using namespace std;

#include "solver.tpp"

int main()
{
    array<array<double, NX>, NY> v;
    array<array<double, NX>, NY> f;

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
