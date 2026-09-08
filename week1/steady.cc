#include <iostream>
#include <chrono>

#include "DyMatrix/matrix.hh"

using namespace std::chrono;

using namespace std;

size_t const MAX_RANK = 300;
size_t const MAX_ITER = 5;

int main()
{
    for (size_t rank = 1; rank != MAX_RANK; ++rank)
    {
        Matrix mat1(rank);
        Matrix mat2(rank);

        cout << rank;
        for (size_t _ = 0; _ != MAX_ITER; ++_)
        {
            steady_clock::time_point start = steady_clock::now();
            [[maybe_unused]] auto finmat = mat1 * mat2;
            auto elapsed = steady_clock::now() - start;
            cout << ',' << elapsed.count();
        }
        cout << "\n";
    }
}
