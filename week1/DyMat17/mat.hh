#ifndef Matrix_HH_
#define Matrix_HH_

#include <random>
#include <ostream>
#include <exception>

template <typename data_t>
class Proxy;

template <typename data_t = double>
class Matrix
{
    size_t nRows;
    size_t nCols;
    data_t *d_matrix;

public:
    Matrix(size_t rows, size_t cols);
    Matrix(size_t size);    //for square matrices
    void fill();            //initialises with random numbers
    void clear();           //zeros all values

[[gnu::always_inline]] inline Proxy<data_t> operator[](size_t row);
    //[[gnu::always_inline]] inline data_t operator[](size_t row, size_t col) const;

    template <typename datat>
    friend std::ostream &operator<<(std::ostream &, Matrix<datat> const &);

    size_t rows() const;
    size_t cols() const;
    data_t *data() const;

    ~Matrix();
};

template <typename data_t = double>        //ignoring type conversions...
[[gnu::noinline]] Matrix<data_t> operator*(Matrix<data_t> &lhs,
                               Matrix<data_t> &rhs);


template <typename data_t>
inline size_t Matrix<data_t>::rows() const
{
    return nRows;
}

template <typename data_t>
inline size_t Matrix<data_t>::cols() const
{
    return nCols;
}

#include <cstring>

template <typename data_t>
void Matrix<data_t>::clear()
{
    //memset((void *) d_matrix, 0, nRows * nCols * sizeof(data_t));

    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = 0;
}


template <typename data_t>
Matrix<data_t>::Matrix(size_t rows, size_t cols)
:
    nRows(rows),
    nCols(cols),
    d_matrix(new data_t[rows * cols])
{
    //fill();
}

template <typename data_t>
Matrix<data_t>::Matrix(size_t size)
:
    Matrix(size, size)
{}


template <typename data_t>
Matrix<data_t>::~Matrix()
{
    delete[] d_matrix;
}

#include <cstring>

template <typename data_t>
void Matrix<data_t>::fill()
{
/*
    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = static_cast<data_t>(idx + 2);
*/


    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<data_t> dist(0, 1);

    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = dist(gen);
}

template <typename data_t>
data_t *Matrix<data_t>::data() const
{
        return d_matrix;
}

template <typename data_t>
class Proxy
{
        Matrix<data_t> &d_Mat;
        size_t d_row;

        public:
                Proxy(Matrix<data_t> &Mat, size_t row) : d_Mat(Mat), d_row(row) {}
                data_t &operator[](size_t col){
                        return d_Mat.data()[d_Mat.cols()*d_row + col];
                }
};

template <typename data_t>
Proxy<data_t> Matrix<data_t>::operator[](size_t row)
{
    return Proxy<data_t>{*this, row};
}



template <typename data_t >
Matrix<data_t> operator*(Matrix<data_t> &lhs,
                               Matrix<data_t> &rhs)
{
    if (lhs.cols() != rhs.rows())
        throw std::runtime_error("matrix sizes don't match");

    Matrix<data_t> rv(lhs.rows(), rhs.cols());
    rv.clear();

    for (size_t row = 0; row != lhs.rows(); ++row)
    for (size_t col = 0; col != rhs.cols(); ++col)
    for (size_t mid = 0; mid != lhs.cols(); ++mid)
        rv[row][ col] += lhs[row][mid] * rhs[mid][col];

    return rv;
}

template <typename data_t>
std::ostream &operator<<(std::ostream &out, Matrix<data_t> const &mat)
{
    for (size_t rowN = 0; rowN != mat.rows(); ++rowN)
    {
        for (size_t colN = 0; colN != mat.cols(); ++colN)
            out << mat[rowN][colN] << ' ';
        out << '\n';
    }
    return out;
}

#endif