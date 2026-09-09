#include <iostream>
#include <chrono>
#include <string>

#include "DyMat17/mat.hh"

using namespace std::chrono;

using namespace std;

int main(int argc, char **argv)
{
    size_t const rank = std::stoul(argv[1]);

        Matrix<double> mat1(rank);
        Matrix<double> mat2(rank);
        mat1.fill();
        mat2.fill();

        [[maybe_unused]] auto volatile finmat = mat1 * mat2;
}