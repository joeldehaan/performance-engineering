#include "DyMatrix/matrix.hh"
#include <numeric>
using namespace std;

int main(int argc, char **argv)
{
    size_t size = stoul(argv[1]);
    vector<double> vec;
    vec.reserve(size);

    iota(vec.begin(), vec.end(), 0);

    double *arr = new double[size];

    for (size_t idx = 0; idx < size; ++idx)
        if (idx % (size / 8) == 0)
            arr[idx] = idx / 5;

    Matrix mat(size);
    mat.fill();

    auto ret = mat * vec;   

    span<double> vec2 = {arr, size};

    auto ret2  = mat * vec2;

    delete[] arr;
}