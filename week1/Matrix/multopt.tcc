

template <size_t nRows, size_t commonSz, size_t nCols, typename data_t >
Matrix<nRows, nCols, data_t> operator*(Matrix<nRows, commonSz, data_t> const &lhs, 
                               Matrix<commonSz, nCols, data_t> const &rhs)
{
    Matrix<nRows, nCols, data_t> rv;
    rv.clear();

    for (size_t row = 0; row != nRows; ++row)
    for (size_t col = 0; col != nCols; ++col)
    for (size_t mid = 0; mid != commonSz; ++mid)
        rv[row, col] += lhs[row, mid] * rhs[mid, col];


    return rv;
}
