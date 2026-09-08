#include <iostream>
#include <chrono>

#include "DyMatrix/matrix.hh"

using namespace std::chrono;

using namespace std;

size_t const MAX_RANK = 300;

int main()
{
    for (size_t rank = 1; rank != MAX_RANK; ++rank)
    {
        Matrix mat1(rank);
        Matrix mat2(rank);

        [[maybe_unused]] auto volatile finmat = mat1 * mat2;
    }
}
