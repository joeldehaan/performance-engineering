
template <typename data_t>
data_t &Matrix<data_t>::operator[](size_t row, size_t col)
{
    return d_matrix[nCols * row + col];
}


template <typename data_t>
data_t Matrix<data_t>::operator[](size_t row, size_t col) const
{
    return d_matrix[nCols * row + col];
}
