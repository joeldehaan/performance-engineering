#include <iostream>
#include <chrono>
#include "DyMatrix/perfmatrix.hh"

using namespace std::chrono;

int main()
{
    size_t test = 1;
    while (true)
    {
        Matrix mat1(test);
        Matrix mat2(test);

        std::cout << test;
        auto finmat = mat1 * mat2;

        if (test < 300)
            ++test;
        else if (test < 700)
            test += 10;
        else if (test < 2000)
            test += 100;
        else 
            return 0;
    }
}
