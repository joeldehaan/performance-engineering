

template <typename data_t >
Matrix<data_t> operator*(Matrix<data_t> const &lhs, 
                               Matrix<data_t> const &rhs)
{
    if (lhs.cols() != rhs.rows())
        throw std::runtime_error("matrix sizes don't match"); 

    Matrix<data_t> rv(lhs.rows(), rhs.cols());
    rv.clear();

    for (size_t row = 0; row != lhs.rows(); ++row)
    for (size_t col = 0; col != rhs.cols(); ++col)
    for (size_t mid = 0; mid != lhs.cols(); ++mid)
        rv[row, col] += lhs[row, mid] * rhs[mid, col];

    return rv;
}
