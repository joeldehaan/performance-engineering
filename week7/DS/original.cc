#include <algorithm>
#include <cstring>
#include <iostream>
#include <vector>

using namespace std;

size_t const elementCount = (1 << 14);

struct Small
{
    char flg1;
    double x[7];
    char flg2;
};

struct Big
{
    int rank;
    double x[elementCount];
};

bool sortSmallByX0(Small const &first, Small const &second)
{
    return first.x[0] < second.x[0];
}

bool sortBigByRank(Big const &first, Big const &second)
{
    return first.rank < second.rank;
}

int main()
{
    vector<Small> vsmall(elementCount);
    vector<Big> vbig(elementCount);

    for (size_t index = 0; index < elementCount; ++index)
    {
        vsmall[index].x[0] = elementCount - index;
    }

    for (size_t index = 0; index < elementCount; ++index)
    {
        vbig[index].rank = elementCount - index;
        memset(vbig[index].x, 0, sizeof(vbig[index].x));
    }

    sort(vsmall.begin(), vsmall.end(), sortSmallByX0);

    sort(vbig.begin(), vbig.end(), sortBigByRank);
}



