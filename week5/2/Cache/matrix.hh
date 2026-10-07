#ifndef Matrix_HH_
#define Matrix_HH_

#include <random>
#include <ostream>
#include <type_traits>

template <size_t nRows, size_t nCols, typename data_t = double>
class Matrix
{
    data_t *d_matrix;

public:
    Matrix();
    //void fill();    //initialises with random numbers
    void clear();   //zeros all values

    [[gnu::always_inline]] inline data_t &operator[](size_t row, size_t col);
    [[gnu::always_inline]] inline data_t operator[](size_t row, size_t col) const;
    
    template <size_t nrows, size_t ncols, typename datat>       //print
    friend std::ostream &operator<<(std::ostream &, Matrix<nrows, ncols, datat> const &);

    data_t *data();

    ~Matrix();
};

template <size_t nRows, size_t nCols, typename data_t>
inline data_t *Matrix<nRows, nCols, data_t>::data()
{
    return d_matrix;
}

template <size_t nRows, size_t commonSz, size_t nCols, typename data_t = double>        //ignoring type conversions...
Matrix<nRows, nCols, data_t> operator*(Matrix<nRows, commonSz, data_t> const &lhs, 
                               Matrix<commonSz, nCols, data_t> const &rhs);

template <size_t nRows, size_t nCols, typename data_t>          //matrix vector multiplication
std::vector<data_t> operator*(Matrix<nRows, nCols, data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec);

/*
template <size_t nRows, size_t nCols, typename mat_data_t, typename data_t = double>
std::vector<data_t> operator*(Matrix<nRows, nCols, mat_data_t> const &mat, const std::type_identity_t<const std::span<const data_t>> vec);
*/

template<size_t size, typename data_t = double>     //alias for square matrices
using sqrMatrix = Matrix<size, size, data_t>;

#include "ctor.tcc"
#include "dtor.tcc"
//#include "fill.tcc"
#include "vectmult.tcc"
#include "clear.tcc"
#include "idx.tcc"
#include "multopt.tcc"
#include "print.tcc"

#endif
