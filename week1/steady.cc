#include <iostream>
#include <chrono>
#include "DyMatrix/matrix.hh"

using namespace std::chrono;

int main()
{
    size_t test = 1;
    while (true)
    {
        Matrix mat1(test);
        Matrix mat2(test);

        std::cout << test;
        for (size_t repeat = 0; repeat != 10; ++repeat)
        {
            steady_clock::time_point start = steady_clock::now();
            auto finmat = mat1 * mat2;
            auto elapsed = steady_clock::now() - start;

            std::cout << ',' << elapsed.count();
        }

        std::cout << "\n";

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
