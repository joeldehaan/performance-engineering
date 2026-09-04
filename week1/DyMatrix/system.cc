#include <iostream>
#include <chrono>
#include "matrix.hh"

using namespace std::chrono;

int main()
{
    size_t test = 1;
    while (true)
    {
        Matrix mat1(test);
        Matrix mat2(test);

        std::cout << test;
        for (size_t repeat = 0; repeat != 5; ++repeat)
        {
            system_clock::time_point start = system_clock::now();
            auto finmat = mat1 * mat2;
            auto elapsed = system_clock::now() - start;

            std::cout << ',' << elapsed.count();
        }

        std::cout << "\n";


        if (test < 300)
            ++test;
        else if (test < 700)
            test += 10;
        else if (test < 1400)
              test += 100;
        else 
            return 0;
    }
}
