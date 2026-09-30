
template <typename data_t>
std::vector<data_t> operator*(Matrix<data_t> const &mat, std::type_identity_t<std::span<data_t>> vec)
{
    if (vec.size() != mat.cols())
        throw std::runtime_error("matrix sizes don't match"); 

    std::vector<data_t> ret;
    ret.reserve(vec.size());


    asm("start mat * vector");
    for (size_t row = 0; row != vec.size(); ++row)
    for (size_t col = 0; col != mat.cols(); ++col)
        ret[row] += mat[row, col] * vec[col];

    return ret;
}
