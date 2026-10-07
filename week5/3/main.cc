#include <cstddef>
#include <string>
#include <iostream>
#include <chrono>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <cstdio>
#include <cstring>

using namespace std;

int main(int argc, char **argv)
{
        size_t const nrIters = 1'000'000;
        size_t const nrBytes = 1; // can be changed if so desired
        
        // isolate push/pop on the stack and loop overhead
        auto nullBegin = chrono::steady_clock::now();
        for (size_t _ = 0; _ != nrIters; ++_) 
        {
                void *ptr;
        }
        auto nullEnd = chrono::steady_clock::now();
        auto nullTime = nullEnd - nullBegin;
        
        // total time with allocation and freeing 
        auto totalBegin = chrono::steady_clock::now();
        for (size_t _ = 0; _ != nrIters; ++_) 
        {

                void* ptr = mmap(nullptr, nrBytes, PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE, -1, 0);
                munmap(ptr, nrBytes);
        }
        auto totalEnd = chrono::steady_clock::now();
        auto totalTime = totalEnd - totalBegin;

        // result
        cout << nullTime / nrIters << '\n';
        cout << totalTime / nrIters << '\n';
        auto memTime = totalTime - nullTime;
        cout << memTime / nrIters<< '\n';
}

