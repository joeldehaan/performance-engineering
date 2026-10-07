

template <size_t nRows, size_t nCols, typename data_t>
std::vector<data_t> operator*(Matrix<nRows, nCols, data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec)
{
    if (vec.size() != nCols)
        throw std::runtime_error("matrix sizes don't match");

                        //allocate with sufficient capacity
    std::vector<data_t> ret(nRows, data_t{});

    for (size_t row = 0; row != nCols; ++row)
    {                   //assuming integral-like types
        data_t sum = 0;
        for (size_t col = 0; col != nCols; ++col)
            sum += mat[row, col] * vec[col];
        ret[row] = sum;
    }

    return ret;
}

/*
template <size_t nRows, size_t nCols, typename mat_data_t, typename data_t>
std::vector<data_t> operator*(Matrix<nRows, nCols, mat_data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec)
{
    if (vec.size() != nCols)
        throw std::runtime_error("matrix sizes don't match");

                        //allocate with sufficient capacity
    std::vector<data_t> ret(nRows, data_t{});

    for (size_t row = 0; row != nRows; ++row)
    {                   //assuming integral-like types
        data_t sum = 0;
        for (size_t col = 0; col != nCols; ++col)
            sum += mat[row, col] * vec[col];
        ret[row] = sum;
    }

    return ret;
}
*/
