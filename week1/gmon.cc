#include <iostream>
#include <chrono>
#include <string>

#include "DyMatrix/perfmatrix.hh"

using namespace std::chrono;

int main(int argc; char **argv)
{
    size_t size = stoul(argv[1]);

    Matrix mat1(test);
    Matrix mat2(test);
    mat1.fill();
    mat2.fill();

    auto finmat = mat1 * mat2;
}
