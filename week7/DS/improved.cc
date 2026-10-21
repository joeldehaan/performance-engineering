#include <algorithm>
#include <cstring>
#include <iostream>
#include <vector>

using namespace std;

size_t const elementCount = (1 << 14);

struct alignas(64) Small
{
    char flg1;
    char flg2;
    double x[7];
};

struct BigMeta
{
    int rank;
    int arrayIndex;
};

struct BigArray
{
    double x[elementCount];
};

bool sortSmallByX0(Small const &first, Small const &second)
{
    return first.x[0] < second.x[0];
}

bool sortBigMetaByRank(BigMeta const &first, BigMeta const &second)
{
    return first.rank < second.rank;
}

int main()
{
    vector<Small> vsmall(elementCount);
    vector<BigMeta> vbigMeta(elementCount);
    vector<BigArray> vbigArray(elementCount);

    for (size_t index = 0; index < elementCount; ++index)
    {
        vsmall[index].x[0] = elementCount - index;
    }

    for (size_t index = 0; index < elementCount; ++index)
    {
        vbigMeta[index].rank = elementCount - index;
        vbigMeta[index].arrayIndex = index;
        memset(vbigArray[index].x, 0, sizeof(vbigArray[index].x));
    }

    sort(vsmall.begin(), vsmall.end(), sortSmallByX0);

    sort(vbigMeta.begin(), vbigMeta.end(), sortBigMetaByRank);
}
