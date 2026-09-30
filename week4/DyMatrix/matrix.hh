#ifndef Matrix_HH_
#define Matrix_HH_

#include <random>
#include <ostream>
#include <exception>
#include <span>
#include <vector>
#include <type_traits>

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

    [[gnu::always_inline]] inline data_t &operator[](size_t row, size_t col);
    [[gnu::always_inline]] inline data_t operator[](size_t row, size_t col) const;
    
    template <typename datat>
    friend std::ostream &operator<<(std::ostream &, Matrix<datat> const &);

    size_t rows() const;
    size_t cols() const;

    data_t const *data() const; //non-owning view of data

    ~Matrix();
};

template <typename data_t = double>        //ignoring type conversions...
Matrix<data_t> operator*(Matrix<data_t> const &lhs, 
                               Matrix<data_t> const &rhs);

template <typename data_t>                //vector multiplication
std::vector<data_t> operator*(Matrix<data_t> const &, 
                    const std::type_identity_t<const std::span<const data_t>> vec);

template <typename data_t>
inline data_t const *Matrix<data_t>::data() const
{
    return d_matrix;
}


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

#include "ctor.tcc"
#include "dtor.tcc"
#include "fill.tcc"
#include "clear.tcc"
#include "idx.tcc"
#include "multopt.tcc"
#include "vecmult.tcc"
#include "print.tcc"

#endif
