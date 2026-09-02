
template <typename data_t>
std::ostream &operator<<(std::ostream &out, Matrix<data_t> const &mat)
{
    for (size_t rowN = 0; rowN != mat.rows(); ++rowN)
    {
        for (size_t colN = 0; colN != mat.cols(); ++colN)
            out << mat[rowN, colN] << ' ';
        out << '\n';
    }
    return out;
}
