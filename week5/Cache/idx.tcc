
template <size_t nRows, size_t nCols, typename data_t>
data_t &Matrix<nRows, nCols, data_t>::operator[](size_t row, size_t col)
{
    return d_matrix[nCols * row + col];
}


template <size_t nRows, size_t nCols, typename data_t>
data_t Matrix<nRows, nCols, data_t>::operator[](size_t row, size_t col) const
{
    return d_matrix[nCols * row + col];
}
