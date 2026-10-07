#include <cstring>

template <size_t nRows, size_t nCols, typename data_t>
void Matrix<nRows, nCols, data_t>::clear()
{
    //memset((void *) d_matrix, 0, nRows * nCols * sizeof(data_t));
    
    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = data_t{};
}

