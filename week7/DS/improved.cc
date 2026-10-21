#include <algorithm>
#include <cstring>
#include <iostream>
#include <vector>

int const elementCount = 16384;

struct Small {
    char flg1;
    double x[7];
    char flg2;
};

struct Big {
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
    std::vector<Small> vsmall(elementCount);
    std::vector<Big> vbig(elementCount);

    for (int index = 0; index < elementCount; ++index) {
        vsmall[index].x[0] = elementCount - index;
    }

    for (int index = 0; index < elementCount; ++index) {
        vbig[index].rank = elementCount - index;
        std::memset(vbig[index].x, 0, sizeof(vbig[index].x));
    }

    std::sort(vsmall.begin(), vsmall.end(), sortSmallByX0);

    std::sort(vbig.begin(), vbig.end(), sortBigByRank);

    return 0;
}



