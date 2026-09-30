
template <typename data_t>
std::vector<data_t> operator*(Matrix<data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec)
{
    size_t cols = mat.cols();
    size_t rows = mat.rows();
            [[assume(cols > 0)]];

    if (vec.size() != mat.cols())
        throw std::runtime_error("matrix sizes don't match"); 

                        //allocate with sufficient capacity
    std::vector<data_t> ret(rows, data_t{}); 

    for (size_t row = 0; row != vec.size(); ++row)
    {                   //assuming integral-like types
        data_t sum = 0;                     
        for (size_t col = 0; col != mat.cols(); ++col)
            sum += mat[row, col] * vec[col];
        ret[row] = sum;
    }

    return ret;
}
