
template <typename data_t>
Matrix<data_t>::Matrix(size_t rows, size_t cols) 
: 
    nRows(rows),
    nCols(cols),
    d_matrix(new data_t[rows * cols])
{
    fill();
}

template <typename data_t>
Matrix<data_t>::Matrix(size_t size)
:
    Matrix(size, size)
{}

