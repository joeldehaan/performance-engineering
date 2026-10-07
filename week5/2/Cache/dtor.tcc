
template <size_t nRows, size_t nCols, typename data_t>
Matrix<nRows, nCols, data_t>::~Matrix() 
{
    delete[] d_matrix;
}
