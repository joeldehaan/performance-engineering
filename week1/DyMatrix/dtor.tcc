
template <typename data_t>
Matrix<data_t>::~Matrix() 
{
    delete[] d_matrix;
}
