#include <stdio.h>

long x;

void func()
{
    x += 1;
}

int main()
{
    x = 1;
    func();
    x += 3;

    printf("%ld\n", x);
}