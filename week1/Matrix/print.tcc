
template <size_t nRows, size_t nCols, typename data_t>
std::ostream &operator<<(std::ostream &out, Matrix<nRows, nCols, data_t> const &mat)
{
    for (size_t rowN = 0; rowN != nRows; ++rowN)
    {
        for (size_t colN = 0; colN != nCols; ++colN)
            out << mat[rowN, colN] << ' ';
        out << '\n';
    }
    return out;
}
