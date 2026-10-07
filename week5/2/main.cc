#include "cachedmatrix.hh"
#include <array>
using namespace std;

#define BLOCK_SIZE
static constexpr size_t MatrixSize = (1 << 15);

int main()
{
    cachedMatrix<BLOCK_SIZE, MatrixSize> matrix;
    std::array<MatrixSize, double> 

}