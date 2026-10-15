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

        // print debug
        /*
        for (size_t iy = 0; iy < ny; iy++)
        {
            for (size_t ix = 0; ix < nx; ix++)
            {
                print("{}, ", (*v)[iy][ix]);
            }
            println();
        }
        */

        for (size_t iy = 1; iy < (ny-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++)
            {
                weight += fabs((*v)[iy][ix]);
            }
        }

        weight /= (nx * ny);
        residual /= weight;

        // println("{}, {}", iter, residual);

        if (residual < tolerance)
        {
            println("Converged after {} iterations (nx={}, ny={}, residual={})", iter, nx, ny, residual);
            return;
        }
    }

    println("ERROR: Failed to converge");
}

template <size_t nx, size_t ny>
void solver_split(unique_ptr<Grid<nx, ny>> v, unique_ptr<Grid<nx, ny>> const f, double const tolerance, size_t const maxIter)
{
    auto vpEven = make_unique<Grid<nx, ny / 2>>();
    auto vpOdd = make_unique<Grid<nx, ny / 2>>();

    auto vEven = make_unique<Grid<nx, ny / 2>>();
    auto vOdd = make_unique<Grid<nx, ny / 2>>();

    auto fEven = make_unique<Grid<nx, ny / 2>>();
    auto fOdd = make_unique<Grid<nx, ny / 2>>();

    
    for (size_t iy = 0; iy < ny; iy++)
    {
        for (size_t ix = 0; ix < nx; ix++)
        {
            bool const odd = ((ix + iy) % 2);
            (odd ? *vOdd : *vEven)[iy / 2][ix] = (*v)[iy][ix];
        }
    }

    for (size_t iy = 0; iy < ny; iy++)
    {
        for (size_t ix = 0; ix < nx; ix++)
        {
            bool const odd = ((ix + iy) % 2);
            (odd ? *fOdd : *fEven)[iy / 2][ix] = (*f)[iy][ix];
        }
    }

    for (size_t iter = 0; iter < maxIter; ++iter)
    {
        double residual = 0.0;
        
        // updating step
        for (size_t iy = 0; iy < ny/2-1; iy++)
        {
            for (size_t ix = 0; ix < nx/2-1; ix++ )
            {
                (*vpEven)[iy][2*ix+1] = -0.25 * ((*fEven)[iy][2*ix+1] -
                    ((*vOdd)[iy][2*ix] + (*vOdd)[iy][2*ix+1] +
                     (*vOdd)[iy][2*ix+2] + (*vOdd)[iy+1][2*ix+1]));

                (*vpEven)[iy+1][2*ix+2] = -0.25 * ((*fEven)[iy+1][2*ix+2] -
                    ((*vOdd)[iy+1][2*ix+1] + (*vOdd)[iy+1][2*ix+2] +
                     (*vOdd)[iy+1][2*ix+3] + (*vOdd)[iy][2*ix+2]));
            }
        }

        for (size_t iy = 0; iy < ny/2; iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++ )
            {
                double diff;
                diff = fabs((*vpEven)[iy][ix] - (*vEven)[iy][ix]);
                residual = max(diff, residual);
            }
        }

        for (size_t iy = 0; iy < (ny/2-1); iy++)
        {
            for (size_t ix = 0; ix < (nx/2-1); ix++ )
            {

                (*vpOdd)[iy][2*ix+2] = -0.25 * ((*fOdd)[iy][2*ix+2] -
                    ((*vEven)[iy][2*ix+1] + (*vEven)[iy][2*ix+2] +
                     (*vEven)[iy][2*ix+3] + (*vEven)[iy+1][2*ix+2]));

                (*vpOdd)[iy+1][2*ix+1] = -0.25 * ((*fOdd)[iy+1][2*ix+1] -
                    ((*vEven)[iy+1][2*ix] + (*vEven)[iy+1][2*ix+1] +
                     (*vEven)[iy+1][2*ix+2] + (*vEven)[iy][2*ix+1]));
            }
        }

        for (size_t iy = 1; iy < (ny/2-1); iy++)
        {
            for (size_t ix = 1; ix < (nx-1); ix++ )
            {
                double diff;
                diff = fabs((*vpOdd)[iy][ix] - (*vOdd)[iy][ix]);
                residual = max(diff, residual);
            }
        }

        // swap v and compute error as well as error weight factor
        double weight = 0.0;

        swap(vEven, vpEven);
        swap(vOdd, vpOdd);


        for (size_t iy = 0; iy < ny/2; iy++)
        {
            (*vEven)[iy][0] = (*vEven)[iy][nx-2];
            (*vOdd)[iy][0] = (*vOdd)[iy][nx-2];

            (*vOdd)[iy][nx-1] = (*vOdd)[iy][1];
            (*vEven)[iy][nx-1] = (*vEven)[iy][1];
        }

        for (size_t ix = 0; ix < nx/2; ix++)
        {
            (*vEven)[0][2*ix] = (*vEven)[ny/2-1][2*ix];
            (*vEven)[ny/2-1][2*ix+1] = (*vEven)[0][2*ix+1];

            (*vOdd)[ny/2-1][2*ix] = (*vOdd)[0][2*ix];
            (*vOdd)[0][2*ix+1] = (*vOdd)[ny/2-1][2*ix+1];
        }
        
        (*vEven)[0][0] = 0;
        (*vEven)[ny/2-1][nx-1] = 0;
        (*vOdd)[0][nx-1] = 0;
        (*vOdd)[ny/2-1][0] = 0;

        // print debug
        /*
        println("{}", (*vOdd)[0][nx-2]);
        for (size_t iy = 0; iy < ny; iy++)
        {
            for (size_t ix = 0; ix < nx; ix++)
            {
                bool const odd = ((ix + iy) % 2);
                print("{}, ", (odd ? *vOdd : *vEven)[iy / 2][ix]);
            }
            println();
        }
        */
        
        for (size_t iy = 0; iy < ny/2; iy++)
        {
            for (size_t ix = 0; ix < nx; ix++)
            {
                weight += fabs((*vEven)[iy][ix]);
                weight += fabs((*vOdd)[iy][ix]);
            }
        }

        weight /= (nx * ny);
        residual /= weight;

        // println("{}, {}", iter, residual);

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

    solver_split(move(v), move(f), EPS, NMAX);
}

