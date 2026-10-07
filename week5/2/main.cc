#include "cachedmatrix.hh"
#include <array>
#include <numeric>
#include <iostream>
using namespace std;

#define BLOCK_SIZE (1 << 8)
static constexpr size_t MatrixSize = (1 << 16);

int main()
{
    cachedMatrix<BLOCK_SIZE, MatrixSize> matrix;
    std::array<double, MatrixSize> vec;

    iota(vec.begin(), vec.end(), 0);        //fill in with values

    auto ret = matrix * vec; 

    for (auto val : ret)
        cout << val;
}