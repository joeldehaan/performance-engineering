// Sum of squares with an unroll factor UNROLL and UNROLL independent
// accumulators (the "dependency break").
//
// Compile-time switches (-D...):
//   UNROLL=n   number of accumulators = unroll factor (default 4)
//   N=n        array length in elements (default 2048 doubles = 16 KiB,
//              which fits into the 32 KiB L1 data cache of one Zen 2 core)
//   CALLS=n    number of times sqsum() is called (default 500000)
//   USE_FMA    use std::fma instead of separate multiply and add

#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <span>
#include <vector>

#ifndef UNROLL
#define UNROLL 4
#endif
#ifndef N
#define N 2048
#endif
#ifndef CALLS
#define CALLS 500000
#endif

// Turns the number UNROLL into a string so it can be used inside _Pragma.
#define STR_(x) #x
#define STR(x) STR_(x)

// noinline: keeps sqsum as its own function, so the assembly is easy to find.
[[gnu::noinline]] double sqsum(std::span<const double> a) {
    constexpr std::size_t U = UNROLL;
    double s[U] = {};   // one partial sum per chain
    std::size_t i = 0;

    for (; i + U <= a.size(); i += U) {
        _Pragma(STR(GCC unroll UNROLL))
        for (std::size_t k = 0; k < U; ++k) {
#ifdef USE_FMA
            s[k] = std::fma(a[i + k], a[i + k], s[k]);
#else
            s[k] += a[i + k] * a[i + k];
#endif
        }
    }

    double total = 0.0;
    for (; i < a.size(); ++i)   // leftover elements (fewer than U)
        total += a[i] * a[i];
    for (double p : s)          // combine the partial sums
        total += p;
    return total;
}

int main() {
    std::vector<double> a(N);
    for (std::size_t i = 0; i < N; ++i)
        a[i] = 1.0 / static_cast<double>(i + 1);   // nonzero data

    double sink = 0.0;
    auto t0 = std::chrono::steady_clock::now();
    for (int c = 0; c < CALLS; ++c) {
        // Empty asm statement that "may change memory": stops the compiler
        // from noticing that every call gives the same answer and running
        // it only once.
        asm volatile("" : : "r"(a.data()) : "memory");
        sink += sqsum(a);
    }
    auto t1 = std::chrono::steady_clock::now();

    double ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
    // Output: nanoseconds per element, then a checksum (so the result is used)
    std::printf("%.4f %.6f\n", ns / (static_cast<double>(CALLS) * N), sink);
}
