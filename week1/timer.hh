#ifndef TIMERCLASS
#define TIMERCLASS

#include <time.h>

struct Timer
{
    system_clock::time_point now;
    Timer();
    ~Timer();
}


#endif
