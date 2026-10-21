// Benchmark for Lab Assignment 7, task 1c.
// Usage: ./bench <variant> <repetitions> [--init-only]
//   variant: small-original | small-optimized | big-original | big-optimized
// Each repetition resets the sort keys (not measured) and sorts (measured).
// When run under `perf stat --control fifo:...` with PERF_CTL_FIFO and
// PERF_ACK_FIFO set, only the sorts are counted.

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <string>
#include <string_view>
#include <unistd.h>
#include <vector>

namespace
{

// Small keeps the assignment's size; Big is reduced from 2^14 so the whole
// measurement fits in about a minute (2^13 elements of 64 KiB = 512 MiB).
std::size_t const smallElementCount = (1 << 14);
std::size_t const bigElementCount = (1 << 13);

struct SmallOriginal
{
    char flg1;
    double x[7];
    char flg2;
};

struct alignas(64) SmallOptimized
{
    char flg1;
    char flg2;
    double x[7];
};

struct BigOriginal
{
    int rank;
    double x[bigElementCount];
};

struct BigMeta
{
    int rank;
    int arrayIndex;
};

struct BigArray
{
    double x[bigElementCount];
};

static_assert(sizeof(SmallOriginal) == 72);
static_assert(sizeof(SmallOptimized) == 64);
static_assert(sizeof(BigMeta) == 8);

enum class Variant
{
    SmallOriginal,
    SmallOptimized,
    BigOriginal,
    BigOptimized,
    Invalid
};

struct BenchmarkSettings
{
    int repetitions;
    bool performSort;
};

class PerfControl
{
public:
    PerfControl()
        : controlFd(openFromEnvironment("PERF_CTL_FIFO", O_WRONLY)),
          ackFd(openFromEnvironment("PERF_ACK_FIFO", O_RDONLY))
    {
    }

    PerfControl(PerfControl const &) = delete;
    PerfControl &operator=(PerfControl const &) = delete;

    ~PerfControl()
    {
        closeIfOpen(controlFd);
        closeIfOpen(ackFd);
    }

    void enable() const
    {
        send("enable\n");
    }

    void disable() const
    {
        send("disable\n");
    }

private:
    static int openFromEnvironment(char const *const variableName, int const flags)
    {
        char const *const path = std::getenv(variableName);
        if (path == nullptr)
        {
            return -1;
        }
        return open(path, flags);
    }

    static void closeIfOpen(int const fileDescriptor)
    {
        if (fileDescriptor >= 0)
        {
            close(fileDescriptor);
        }
    }

    void send(std::string_view const command) const
    {
        if (controlFd < 0 || ackFd < 0)
        {
            return;
        }
        if (write(controlFd, command.data(), command.size()) < 0)
        {
            return;
        }
        waitForAck();
    }

    void waitForAck() const
    {
        std::string received;
        char buffer[16];
        while (received.find("ack") == std::string::npos)
        {
            ssize_t const bytesRead = read(ackFd, buffer, sizeof(buffer));
            if (bytesRead <= 0)
            {
                return;
            }
            received.append(buffer, static_cast<std::size_t>(bytesRead));
        }
    }

    int const controlFd;
    int const ackFd;
};

template <typename SmallType>
bool compareSmallByX0(SmallType const &first, SmallType const &second)
{
    return first.x[0] < second.x[0];
}

template <typename SmallType>
void resetSmall(std::vector<SmallType> &elements)
{
    for (std::size_t index = 0; index < elements.size(); ++index)
    {
        elements[index].x[0] = static_cast<double>(elements.size() - index);
    }
}

template <typename SmallType>
double benchmarkSmall(BenchmarkSettings const &settings, PerfControl const &perfControl)
{
    std::vector<SmallType> elements(smallElementCount);
    for (int repetition = 0; repetition < settings.repetitions; ++repetition)
    {
        resetSmall(elements);
        perfControl.enable();
        if (settings.performSort)
        {
            std::sort(elements.begin(), elements.end(), compareSmallByX0<SmallType>);
        }
        perfControl.disable();
    }
    return elements.front().x[0] + elements.back().x[0];
}

bool compareBigOriginalByRank(BigOriginal const &first, BigOriginal const &second)
{
    return first.rank < second.rank;
}

void resetBigOriginal(std::vector<BigOriginal> &elements)
{
    for (std::size_t index = 0; index < elements.size(); ++index)
    {
        elements[index].rank = static_cast<int>(elements.size() - index);
    }
}

double benchmarkBigOriginal(BenchmarkSettings const &settings, PerfControl const &perfControl)
{
    std::vector<BigOriginal> elements(bigElementCount);
    for (BigOriginal &element : elements)
    {
        std::memset(element.x, 0, sizeof(element.x));
    }
    for (int repetition = 0; repetition < settings.repetitions; ++repetition)
    {
        resetBigOriginal(elements);
        perfControl.enable();
        if (settings.performSort)
        {
            std::sort(elements.begin(), elements.end(), compareBigOriginalByRank);
        }
        perfControl.disable();
    }
    return elements.front().rank + elements.back().x[0];
}

bool compareBigMetaByRank(BigMeta const &first, BigMeta const &second)
{
    return first.rank < second.rank;
}

void resetBigMeta(std::vector<BigMeta> &metas)
{
    for (std::size_t index = 0; index < metas.size(); ++index)
    {
        metas[index].rank = static_cast<int>(metas.size() - index);
        metas[index].arrayIndex = static_cast<int>(index);
    }
}

double benchmarkBigOptimized(BenchmarkSettings const &settings, PerfControl const &perfControl)
{
    std::vector<BigMeta> metas(bigElementCount);
    std::vector<BigArray> arrays(bigElementCount);
    for (BigArray &array : arrays)
    {
        std::memset(array.x, 0, sizeof(array.x));
    }
    for (int repetition = 0; repetition < settings.repetitions; ++repetition)
    {
        resetBigMeta(metas);
        perfControl.enable();
        if (settings.performSort)
        {
            std::sort(metas.begin(), metas.end(), compareBigMetaByRank);
        }
        perfControl.disable();
    }
    return metas.front().rank + arrays[metas.front().arrayIndex].x[0];
}

Variant parseVariant(std::string_view const name)
{
    if (name == "small-original")
    {
        return Variant::SmallOriginal;
    }
    if (name == "small-optimized")
    {
        return Variant::SmallOptimized;
    }
    if (name == "big-original")
    {
        return Variant::BigOriginal;
    }
    if (name == "big-optimized")
    {
        return Variant::BigOptimized;
    }
    return Variant::Invalid;
}

double runVariant(Variant const variant, BenchmarkSettings const &settings)
{
    PerfControl const perfControl;
    switch (variant)
    {
    case Variant::SmallOriginal:
        return benchmarkSmall<SmallOriginal>(settings, perfControl);
    case Variant::SmallOptimized:
        return benchmarkSmall<SmallOptimized>(settings, perfControl);
    case Variant::BigOriginal:
        return benchmarkBigOriginal(settings, perfControl);
    case Variant::BigOptimized:
        return benchmarkBigOptimized(settings, perfControl);
    case Variant::Invalid:
        break;
    }
    return 0.0;
}

} // namespace

int main(int const argumentCount, char **const arguments)
{
    if (argumentCount < 3)
    {
        std::fprintf(stderr, "usage: %s <variant> <repetitions> [--init-only]\n", arguments[0]);
        return 1;
    }
    Variant const variant = parseVariant(arguments[1]);
    if (variant == Variant::Invalid)
    {
        std::fprintf(stderr, "unknown variant: %s\n", arguments[1]);
        return 1;
    }
    bool const initOnly = argumentCount > 3 && std::string_view(arguments[3]) == "--init-only";
    BenchmarkSettings const settings{std::atoi(arguments[2]), !initOnly};
    double const checksum = runVariant(variant, settings);
    std::printf("checksum %f\n", checksum);
    return 0;
}
