#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <utility>
#include <array>
#include <print>
#include <memory>
#include <algorithm>

using namespace std;

template <size_t nx, size_t ny>
using Grid = array<array<double, nx>, ny>;

template <size_t nx, size_t ny>
void solver(unique_ptr<Grid<nx, ny>> v, unique_ptr<Grid<nx, ny>> const f, double const tolerance, size_t const maxIter)
{
    auto vp = make_unique<Grid<nx, ny>>();

    for (size_t iter = 0; iter < maxIter; ++iter)
    {
        double residual = 0.0;

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++ )
            {
                double diff;

                (*vp)[iy][ix] = -0.25 * ((*f)[iy][ix] -
                    ((*v)[iy][ix+1] + (*v)[iy][ix-1] +
                     (*v)[iy+1][ix] + (*v)[iy-1][ix]));

                diff = fabs((*vp)[iy][ix] - (*v)[iy][ix]);
                residual = max(diff, residual);
            }
        }

        // Update v and compute error as well as error weight factor
        double weight = 0.0;

        swap(v, vp); // identical since vp is immediately written to next loop cycle

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            (*v)[iy][0] = (*v)[iy][nx-2];
            (*v)[iy][nx-1] = (*v)[iy][1];
            weight += fabs((*v)[iy][0]) + fabs((*v)[iy][nx-1]);
        }

        for (size_t ix = 1; ix < (nx-1); ix++)
        {
            (*v)[0][ix] = (*v)[ny-2][ix];
            (*v)[ny-1][ix] = (*v)[1][ix];
            weight += fabs((*v)[0][ix]) + fabs((*v)[ny-1][ix]);
        }

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++)
            {
                weight += fabs((*v)[iy][ix]);
            }
        }

        weight /= (nx * ny);
        residual /= weight;

        if (residual < tolerance)
        {
            println("Converged after {} iterations (nx={}, ny={}, residual={})", iter, nx, ny, residual);
            return;
        }
    }

    println("ERROR: Failed to converge");
}

#ifndef NX
#define NX 1024
#endif
#ifndef NY
#define NY 16
#endif
#define NMAX 200000
#define EPS 1e-5

int main()
{
    auto v = make_unique<Grid<NX, NY>>();
    auto f = make_unique<Grid<NX, NY>>();

    // Initialise input
    for (size_t iy = 0; iy < NY; iy++)
    {
        for (size_t ix = 0; ix < NX; ix++)
        {
            (*v)[iy][ix] = 0.0;

            double const x = 2.0 * ix / (NX - 1.0) - 1.0;
            double const y = 2.0 * iy / (NY - 1.0) - 1.0;
            (*f)[iy][ix] = sin(x + y);
        }
    }

    solver(move(v), move(f), EPS, NMAX);
}

