#ifndef CACHED_MATRIX
#define CACHED_MATRIX

#include "Cache/matrix.hh"
#include <concepts>

template <size_t block, size_t size, typename data_t = double>
    requires (block > 0 && size % block == 0)
using cachedMatrix = sqrMatrix<size / block, sqrMatrix<block, data_t>>;

#endif
