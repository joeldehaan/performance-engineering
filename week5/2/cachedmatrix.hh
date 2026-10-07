#ifndef CACHED_MATRIX
#define CACHED_MATRIX

#include "Cache/matrix.hh"
#include <concepts>

template <size_t block, size_t size, typename data_t = double>
    requires (block > 0 && size % block == 0)
using cachedMatrix = sqrMatrix<size / block, sqrMatrix<block, data_t>>;

template <size_t tRows, size_t tCols, size_t bRows, size_t bCols, typename data_t>
std::vector<data_t> operator*(Matrix<tRows, tCols, Matrix<bRows, bCols, data_t>> const &mat,
                         std::type_identity_t<std::span<const data_t>> vec)
{
    if (vec.size() != tCols * bCols)
        throw std::runtime_error("matrix sizes don't match");

    std::vector<data_t> ret(tRows * bRows, data_t{});

    for (size_t ti = 0; ti != tRows; ++ti)
    for (size_t tj = 0; tj != tCols; ++tj)
    {
        auto const &tile = mat[ti, tj];
        data_t const *x = vec.data() + tj * bCols;
        data_t *y = ret.data() + ti * bRows;

        for (size_t i = 0; i != bRows; ++i)
        {
            data_t sum{};
            for (size_t j = 0; j != bCols; ++j)
                sum += tile[i, j] * x[j];
            y[i] += sum;
        }
    }
    return ret;
}

/*
template <size_t Block, size_t Size, typename data_t>
std::vector<data_t> operator*(cachedMatrix<Block, Size, data_t> const &mat, 
                                const std::type_identity_t<const std::span<const data_t>> vec)
{
    if (vec.size() != Size)
        throw std::runtime_error("matrix sizes don't match");

    std::vector<data_t> ret(Size, data_t{});

    for (size_t ti = 0; ti != Size; ++ti)
    for (size_t tj = 0; tj != Size; ++tj)
    {
        auto const &tile = mat[ti, tj];                 
        data_t const *x = vec.data() + tj * Block;           
        data_t *y = ret.data() + ti * Block;                 

        for (size_t i = 0; i != Block; ++i)
        {
            data_t sum{};
            for (size_t j = 0; j != Block; ++j)
                sum += tile[i, j] * x[j];
            y[i] += sum;
        }
    }
    return ret;
}
*/

#endif
