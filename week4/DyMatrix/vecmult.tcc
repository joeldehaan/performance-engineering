
template <typename data_t>
std::vector<data_t> operator*(Matrix<data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec)
{
    size_t cols = mat.cols();
    size_t rows = mat.rows();
            [[assume(cols > 0)]];

    if (vec.size() != mat.cols())
        throw std::runtime_error("matrix sizes don't match"); 

    std::vector<data_t> ret;
    ret.reserve(cols);


    for (size_t row = 0; row != vec.size(); ++row)
    for (size_t col = 0; col != mat.cols(); ++col)
        ret[row] += mat[row, col] * vec[col];
/*

    data_t const *__restrict mp = mat.data();
    data_t const *__restrict vp = vec.data();
    data_t *__restrict rp = ret.data();     //forcing restrict: g++


    for (size_t row = 0; row < rows; ++row) 
    {
        data_t const *__restrict mrow = mp + row * cols;
        data_t sum = 0;     //prevent constant access

        for (size_t col = 0; col < cols; ++col)
            sum += mrow[col] * vp[col];
        rp[row] = sum;
    }
*/
    return ret;
}
