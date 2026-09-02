#ifndef Matrix_HH_
#define Matrix_HH_

#include <random>
#include <ostream>

template <size_t nRows, size_t nCols, typename data_t = double>
class Matrix
{
    data_t *d_matrix;

public:
    Matrix();
    void fill();    //initialises with random numbers
    void clear();   //zeros all values

    [[gnu::always_inline]] inline data_t &operator[](size_t row, size_t col);
    [[gnu::always_inline]] inline data_t operator[](size_t row, size_t col) const;
    
    template <size_t nrows, size_t ncols, typename datat>
    friend std::ostream &operator<<(std::ostream &, Matrix<nrows, ncols, datat> const &);

    ~Matrix();
};

template <size_t nRows, size_t commonSz, size_t nCols, typename data_t = double>        //ignoring type conversions...
Matrix<nRows, nCols, data_t> operator*(Matrix<nRows, commonSz, data_t> const &lhs, 
                               Matrix<commonSz, nCols, data_t> const &rhs);


#include "ctor.tcc"
#include "dtor.tcc"
#include "fill.tcc"
#include "clear.tcc"
#include "idx.tcc"
#include "multopt.tcc"
#include "print.tcc"

#endif
