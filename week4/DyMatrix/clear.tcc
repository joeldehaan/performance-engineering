#include <cstring>

template <typename data_t>
void Matrix<data_t>::clear()
{
    //memset((void *) d_matrix, 0, nRows * nCols * sizeof(data_t));
    
    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = 0;
}

