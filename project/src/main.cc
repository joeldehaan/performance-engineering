#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <utility>
#include <array>
#include <print>
#include <memory>
#include <chrono>
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

        // println("{}, {}", iter, residual);

        if (residual < tolerance)
        {
            println("Converged after {} iterations (nx={}, ny={}, residual={})", iter, nx, ny, residual);
            return;
        }
    }

    println("ERROR: Failed to converge");
}

// Red-black (checkerboard) Jacobi sweep with a unit-stride "packed" layout.
//
// The colour of grid point (ix, iy) is (ix + iy) % 2. For every full-grid row iy
// each colour owns only every second column, so the values of one colour in one
// row are stored contiguously: plane[color][iy][ix / 2]. In row iy the point of
// colour c sits at ix = 2 * packed + startParity with startParity = (c + iy) % 2,
// and its four neighbours (all of colour 1 - c) are
//     left/right : other[iy][packed - 1], other[iy][packed]     (startParity == 0)
//                  other[iy][packed],     other[iy][packed + 1] (startParity == 1)
//     up/down    : other[iy - 1][packed], other[iy + 1][packed]
// so every stencil read is a plain, shifted, unit-stride load. The residual max
// and the weight sum are fused into the update loop, and the periodic wrap uses
// row index wrapping (no ghost-row copies) plus one scalar ghost-column copy per
// row and colour.
//
// Same numerics as solver(): Jacobi update on rows 1..ny-2 / columns 1..nx-2,
// residual = max|vp - v| / mean|v|, with the mean over the full grid including the
// periodic ghost cells (corners excluded, they are zero in solver()).
// Note: the ghost rows of the *initial* solution are not read (they are implied
// by the periodic wrap); the ghost columns of the initial solution are.
template <size_t nx, size_t ny>
void solver_split(unique_ptr<Grid<nx, ny>> solution, unique_ptr<Grid<nx, ny>> const source, double const tolerance, size_t const maxIter)
{
    static_assert(nx % 2 == 0 && ny % 2 == 0 && ny >= 4, "red-black split needs even nx, ny (ny >= 4)");

    constexpr size_t packedWidth = nx / 2;
    constexpr size_t pointsPerSweep = packedWidth - 1;                  // updated points per row and colour
    constexpr size_t vectorizedPoints = pointsPerSweep / 4 * 4;

    using Plane = array<array<double, packedWidth>, ny>;

    // 4-wide SIMD through the GCC/Clang vector extension (AVX2 with -march=native).
    // Written by hand so it does not depend on the auto-vectoriser.
    using Vec4 = double __attribute__((vector_size(32), aligned(8), may_alias));
    using Vec4Int = long long __attribute__((vector_size(32)));

    constexpr long long magnitudeBits = 0x7fffffffffffffffLL;
    constexpr Vec4Int absMask = { magnitudeBits, magnitudeBits, magnitudeBits, magnitudeBits };

    auto const load = [](double const *const address)
    {
        return *reinterpret_cast<Vec4 const *>(address);
    };

    auto const store = [](double *const address, Vec4 const value)
    {
        *reinterpret_cast<Vec4 *>(address) = value;
    };

    auto const vectorAbs = [absMask](Vec4 const value)
    {
        return __builtin_bit_cast(Vec4, __builtin_bit_cast(Vec4Int, value) & absMask);
    };

    array<unique_ptr<Plane>, 2> current = { make_unique<Plane>(), make_unique<Plane>() };
    array<unique_ptr<Plane>, 2> next = { make_unique<Plane>(), make_unique<Plane>() };
    array<unique_ptr<Plane>, 2> const rightHandSide = { make_unique<Plane>(), make_unique<Plane>() };

    for (size_t iy = 0; iy < ny; ++iy)
    {
        for (size_t ix = 0; ix < nx; ++ix)
        {
            size_t const color = (ix + iy) % 2;
            (*current[color])[iy][ix / 2] = (*solution)[iy][ix];
            (*rightHandSide[color])[iy][ix / 2] = (*source)[iy][ix];
        }
    }

    double residual = 0.0;
    double weight = 0.0;

    // Updates colour `color` of row `row` (startParity = (color + row) % 2); `rowAbove`
    // and `rowBelow` are the (periodically wrapped) neighbouring rows. Folds the
    // row's maximum change into `residual`, its ghost column into `weight` and the
    // sum of its new values into `rowSum`.
    auto const sweep = [&]<int startParity>(size_t const color, size_t const row, size_t const rowAbove, size_t const rowBelow, double &rowSum)
    {
        constexpr size_t firstPacked = 1 - startParity;

        double *const outRow = (*next[color])[row].data();
        double *const __restrict out = outRow + firstPacked;
        double const *const __restrict old = (*current[color])[row].data() + firstPacked;
        double const *const __restrict rhs = (*rightHandSide[color])[row].data() + firstPacked;
        double const *const __restrict side = (*current[1 - color])[row].data();
        double const *const __restrict above = (*current[1 - color])[rowAbove].data() + firstPacked;
        double const *const __restrict below = (*current[1 - color])[rowBelow].data() + firstPacked;

        Vec4 maxChange = { 0.0, 0.0, 0.0, 0.0 };
        Vec4 sumValues = { 0.0, 0.0, 0.0, 0.0 };

        size_t point = 0;
        for (; point < vectorizedPoints; point += 4)
        {
            Vec4 const updated = 0.25 * ((load(side + point) + load(side + point + 1)) + (load(above + point) + load(below + point)) - load(rhs + point));
            store(out + point, updated);

            Vec4 const change = vectorAbs(updated - load(old + point));
            maxChange = (change > maxChange) ? change : maxChange;
            sumValues += vectorAbs(updated);
        }

        double rowMaxChange = max(max(maxChange[0], maxChange[1]), max(maxChange[2], maxChange[3]));
        double rowValueSum = (sumValues[0] + sumValues[1]) + (sumValues[2] + sumValues[3]);

        // scalar tail (pointsPerSweep % 4 points)
        for (; point < pointsPerSweep; ++point)
        {
            double const updated = 0.25 * ((side[point] + side[point + 1]) + (above[point] + below[point]) - rhs[point]);
            out[point] = updated;

            rowMaxChange = max(rowMaxChange, fabs(updated - old[point]));
            rowValueSum += fabs(updated);
        }

        // periodic ghost column (one value per row and colour)
        if constexpr (startParity == 0)
        {
            outRow[0] = outRow[packedWidth - 1];
            weight += fabs(outRow[0]);
        }
        else
        {
            outRow[packedWidth - 1] = outRow[0];
            weight += fabs(outRow[packedWidth - 1]);
        }

        residual = max(residual, rowMaxChange);
        rowSum += rowValueSum;
    };

    for (size_t iter = 0; iter < maxIter; ++iter)
    {
        residual = 0.0;
        weight = 0.0;

        for (size_t iy = 1; iy < ny - 1; ++iy)
        {
            size_t const rowAbove = (iy == 1) ? ny - 2 : iy - 1;
            size_t const rowBelow = (iy == ny - 2) ? 1 : iy + 1;

            double rowSum = 0.0;
            if (iy % 2 == 0)
            {
                sweep.template operator()<0>(0, iy, rowAbove, rowBelow, rowSum);
                sweep.template operator()<1>(1, iy, rowAbove, rowBelow, rowSum);
            }
            else
            {
                sweep.template operator()<1>(0, iy, rowAbove, rowBelow, rowSum);
                sweep.template operator()<0>(1, iy, rowAbove, rowBelow, rowSum);
            }

            weight += rowSum;
            if (iy == 1 || iy == ny - 2)             // these rows are also the ghost rows 0 / ny-1
            {
                weight += rowSum;
            }
        }

        swap(current, next);

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

