#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <utility>
#include <array>
#include <print>
#include <simd>
#include <bit>
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

        for (size_t iy = 1; iy < (ny - 1); iy++)
        {
            for (size_t ix = 1; ix < (nx - 1); ix++)
            {
                double diff;

                (*vp)[iy][ix] = -0.25 * ((*f)[iy][ix] -
                                         ((*v)[iy][ix + 1] + (*v)[iy][ix - 1] +
                                          (*v)[iy + 1][ix] + (*v)[iy - 1][ix]));

                diff = fabs((*vp)[iy][ix] - (*v)[iy][ix]);
                residual = max(diff, residual);
            }
        }

        // Update v and compute error as well as error weight factor
        double weight = 0.0;

        swap(v, vp); // identical since vp is immediately written to next loop cycle

        for (size_t iy = 1; iy < (ny - 1); iy++)
        {
            (*v)[iy][0] = (*v)[iy][nx - 2];
            (*v)[iy][nx - 1] = (*v)[iy][1];
            weight += fabs((*v)[iy][0]) + fabs((*v)[iy][nx - 1]);
        }

        for (size_t ix = 1; ix < (nx - 1); ix++)
        {
            (*v)[0][ix] = (*v)[ny - 2][ix];
            (*v)[ny - 1][ix] = (*v)[1][ix];
            weight += fabs((*v)[0][ix]) + fabs((*v)[ny - 1][ix]);
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

        for (size_t iy = 1; iy < (ny - 1); iy++)
        {
            for (size_t ix = 1; ix < (nx - 1); ix++)
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

// Red-black (checkerboard) Jacobi solver with a packed, unit-stride layout.
//
// A grid point (ix, iy) has colour (ix + iy) % 2. Within one row a colour owns every
// second column, so its values are stored contiguously: grid[color][iy][ix / 2].
// The point of colour c in row iy sits at ix = 2 * packed + columnParity(c, iy), and
// all four neighbours (colour opposite(c)) are plain shifted loads from the packed
// rows iy - 1, iy and iy + 1. Periodic rows wrap around by index; the periodic ghost
// column costs one scalar copy per row and colour.

namespace
{
    enum class Color : size_t
    {
        red,
        black
    };

    inline constexpr array<Color, 2> allColors = {Color::red, Color::black};

    constexpr Color opposite(Color const color)
    {
        return (color == Color::red) ? Color::black : Color::red;
    }

    constexpr Color colorAt(size_t const ix, size_t const iy)
    {
        return static_cast<Color>((ix + iy) % 2);
    }

    // parity of the full-grid column of the first packed entry of `color` in `row`
    constexpr size_t columnParity(Color const color, size_t const row)
    {
        return (to_underlying(color) + row) % 2;
    }

    // the first packed entry that is an interior column (entry 0 is the ghost column
    // whenever the colour starts on an even column)
    constexpr size_t interiorStart(Color const color, size_t const row)
    {
        return 1 - columnParity(color, row);
    }

    template <size_t ny>
    constexpr size_t rowAbove(size_t const row)
    {
        return (row == 1) ? ny - 2 : row - 1;
    }

    template <size_t ny>
    constexpr size_t rowBelow(size_t const row)
    {
        return (row == ny - 2) ? 1 : row + 1;
    }

    // rows 1 and ny - 2 are also the periodic images of the ghost rows ny - 1 and 0
    template <size_t ny>
    constexpr bool isGhostRowSource(size_t const row)
    {
        return row == 1 || row == ny - 2;
    }

    template <size_t nx, size_t ny>
    using PackedPlane = array<array<double, nx / 2>, ny>;

    template <size_t nx, size_t ny>
    struct ColoredGrid
    {
        array<PackedPlane<nx, ny>, 2> planes;

        PackedPlane<nx, ny> &operator[](Color const color)
        {
            return planes[to_underlying(color)];
        }

        PackedPlane<nx, ny> const &operator[](Color const color) const
        {
            return planes[to_underlying(color)];
        }
    };

    template <size_t nx, size_t ny>
    struct SplitFields
    {
        unique_ptr<ColoredGrid<nx, ny>> current;
        unique_ptr<ColoredGrid<nx, ny>> next;
        unique_ptr<ColoredGrid<nx, ny>> const rightHandSide;
    };

    template <size_t nx, size_t ny>
    unique_ptr<ColoredGrid<nx, ny>> pack(Grid<nx, ny> const &grid)
    {
        auto packed = make_unique<ColoredGrid<nx, ny>>();

        for (size_t iy = 0; iy < ny; ++iy)
        {
            for (size_t ix = 0; ix < nx; ++ix)
            {
                (*packed)[colorAt(ix, iy)][iy][ix / 2] = grid[iy][ix];
            }
        }

        return packed;
    }

    // One row of one colour: where the new values go and everything the stencil reads.
    // `side` is the opposite colour in the same row: its entries i and i + 1 are the left
    // and right neighbours of entry i.
    struct StencilRow
    {
        double *const out;
        double const *const old;
        double const *const rhs;
        double const *const side;
        double const *const above;
        double const *const below;
        ptrdiff_t const points;
    };

    template <size_t nx, size_t ny>
    StencilRow makeStencilRow(SplitFields<nx, ny> &fields, Color const color, size_t const row)
    {
        size_t const start = interiorStart(color, row);
        ColoredGrid<nx, ny> const &current = *fields.current;
        PackedPlane<nx, ny> const &otherColor = current[opposite(color)];

        return StencilRow{
            .out = (*fields.next)[color][row].data() + start,
            .old = current[color][row].data() + start,
            .rhs = (*fields.rightHandSide)[color][row].data() + start,
            .side = otherColor[row].data(),
            .above = otherColor[rowAbove<ny>(row)].data() + start,
            .below = otherColor[rowBelow<ny>(row)].data() + start,
            .points = nx / 2 - 1};
    }

    using Block = simd::vec<double>;

    inline constexpr ptrdiff_t lanes = Block::size();
    inline constexpr double quarter = 0.25;

    Block loadBlock(double const *const source)
    {
        return simd::unchecked_load<Block>(source, lanes);
    }

    void storeBlock(Block const values, double *const destination)
    {
        simd::unchecked_store(values, destination, lanes);
    }

    using Bits = simd::rebind_t<uint64_t, Block>;

    inline constexpr uint64_t magnitudeMask = 0x7fff'ffff'ffff'ffff;

    // simd::abs is only provided for integer vectors: clear the sign bits instead
    Block magnitude(Block const value)
    {
        return bit_cast<Block>(bit_cast<Bits>(value) & Bits(magnitudeMask));
    }

    // works for a Block as well as for a single double
    template <typename Value>
    Value stencil(Value const left, Value const right, Value const above, Value const below, Value const source)
    {
        return quarter * ((left + right) + (above + below) - source);
    }

    struct BlockSums
    {
        Block maxChange = Block(0.0);
        Block valueSum = Block(0.0);
    };

    void processBlock(StencilRow const &row, ptrdiff_t const offset, BlockSums &sums)
    {
        Block const updated = stencil(loadBlock(row.side + offset), loadBlock(row.side + offset + 1), loadBlock(row.above + offset),
                                      loadBlock(row.below + offset), loadBlock(row.rhs + offset));

        storeBlock(updated, row.out + offset);
        sums.maxChange = simd::max(sums.maxChange, magnitude(updated - loadBlock(row.old + offset)));
        sums.valueSum += magnitude(updated);
    }

    struct Totals
    {
        double maxChange = 0.0;
        double interiorSum = 0.0;
        double ghostSum = 0.0;

        Totals &operator+=(Totals const &other)
        {
            maxChange = max(maxChange, other.maxChange);
            interiorSum += other.interiorSum;
            ghostSum += other.ghostSum;
            return *this;
        }
    };

    // the (points % lanes) entries that do not fill a whole Block
    void processTail(StencilRow const &row, ptrdiff_t const offset, Totals &total)
    {
        double const updated = stencil(row.side[offset], row.side[offset + 1], row.above[offset], row.below[offset], row.rhs[offset]);

        row.out[offset] = updated;
        total.maxChange = max(total.maxChange, abs(updated - row.old[offset]));
        total.interiorSum += abs(updated);
    }

    Totals sweepRow(StencilRow const row)
    {
        BlockSums sums;

        ptrdiff_t offset = 0;
        for (; offset + lanes <= row.points; offset += lanes)
        {
            processBlock(row, offset, sums);
        }

        Totals total = {.maxChange = simd::reduce_max(sums.maxChange), .interiorSum = simd::reduce(sums.valueSum)};
        for (; offset < row.points; ++offset)
        {
            processTail(row, offset, total);
        }

        return total;
    }

    // copies the periodic image into the ghost column of a packed row and returns it
    template <size_t width>
    double fillGhostColumn(array<double, width> &packedRow, size_t const parity)
    {
        size_t const ghost = (parity == 0) ? 0 : width - 1;
        size_t const image = (parity == 0) ? width - 1 : 0;

        packedRow[ghost] = packedRow[image];
        return packedRow[ghost];
    }

    template <size_t nx, size_t ny>
    Totals updateRow(SplitFields<nx, ny> &fields, size_t const row)
    {
        Totals total;

        for (Color const color : allColors)
        {
            total += sweepRow(makeStencilRow(fields, color, row));
            total.ghostSum += fabs(fillGhostColumn((*fields.next)[color][row], columnParity(color, row)));
        }

        return total;
    }

#pragma omp declare reduction(+ : Totals : omp_out += omp_in) \
    initializer(omp_priv = Totals{})

    template <size_t nx, size_t ny>
    Totals updateAllRows(SplitFields<nx, ny> &fields)
    {
        Totals total;

#pragma omp parallel for schedule(static) reduction(+ : total)
        for (size_t row = 1; row < ny - 1; ++row)
        {
            Totals const rowTotal = updateRow(fields, row);
            total += rowTotal;

            if (isGhostRowSource<ny>(row))
            {
                total.ghostSum += rowTotal.interiorSum;
            }
        }

        return total;
    }

    template <size_t nx, size_t ny>
    double relativeResidual(Totals const &total)
    {
        double const meanMagnitude = (total.interiorSum + total.ghostSum) / (nx * ny);
        return total.maxChange / meanMagnitude;
    }

} // namespace

template <size_t nx, size_t ny>
void solver_split(unique_ptr<Grid<nx, ny>> solution, unique_ptr<Grid<nx, ny>> const source, double const tolerance, size_t const maxIter)
{
    static_assert(nx % 2 == 0 && ny % 2 == 0 && ny >= 4, "red-black split needs even nx, ny (ny >= 4)");

    SplitFields<nx, ny> fields = {pack(*solution), make_unique<ColoredGrid<nx, ny>>(), pack(*source)};

    for (size_t iter = 0; iter < maxIter; ++iter)
    {
        Totals const total = updateAllRows(fields);
        swap(fields.current, fields.next);

        double const residual = relativeResidual<nx, ny>(total);
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
#define NMAX 50000
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
