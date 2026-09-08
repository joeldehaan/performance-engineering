#include <iostream>
#include <chrono>
#include <string>

#include "DyMatrix/perfmatrix.hh"

using namespace std::chrono;

using namespace std;

int main(int argc, char **argv)
{
    size_t const rank = stoul(argv[1]);

    Matrix mat1(rank);
    Matrix mat2(rank);
    mat1.fill();
    mat2.fill();

    auto finmat = mat1 * mat2;
}
