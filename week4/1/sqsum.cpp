#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <span>
#include <vector>
#include <iostream>

#ifndef UNROLL
#define UNROLL 4
#endif
#ifndef N
#define N 2048
#endif
#ifndef CALLS
#define CALLS 500000
#endif

#define STR_(x) #x
#define STR(x) STR_(x)

using namespace std;

[[gnu::noinline]] double sqsum(span<const double> arr)
{
    constexpr std::size_t U = UNROLL;
    double s[U] = {};   // one partial sum per chain

    std::size_t idx = 0;
    for (; idx + U <= arr.size(); idx += U)
    {
        _Pragma(STR(GCC unroll UNROLL))
        for (size_t k = 0; k < U; ++k)
        {
#ifdef USE_FMA
            s[k] = std::fma(arr[idx + k], arr[idx + k], s[k]);
#else
            s[k] += arr[idx + k] * arr[idx + k];
#endif
        }
    }

    double total = 0.0;
    for (; idx < arr.size(); ++idx)
        total += arr[idx] * arr[idx];
    for (double p : s)
        total += p;
    return total;
}

int main()
{
    vector<double> arr(N);
    for (size_t idx = 0; idx < N; ++idx)
        arr[idx] = 1.0 / static_cast<double>(idx + 1);

    double sink = 0.0;
    auto t0 = chrono::steady_clock::now();
    for (size_t c = 0; c < CALLS; ++c)
    {
        asm volatile("" : : "r"(arr.data()) : "memory");
        sink += sqsum(arr);
    }
    auto t1 = chrono::steady_clock::now();

    double ns = chrono::duration<double, nano>(t1 - t0).count();

    cout << ns / (static_cast<double>(CALLS) * N) << ' ' << sink << '\n';
}
