
template <size_t nRows, size_t nCols, typename data_t>
Matrix<nRows, nCols, data_t>::Matrix() 
: 
    d_matrix(new data_t[nRows * nCols])
{
    fill();
}
