#include <cstring>

template <typename data_t>
void Matrix<data_t>::fill()
{
    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = static_cast<data_t>(idx + 2);


    /*
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<data_t> dist(0, 1);

    for (size_t idx = 0; idx != nRows * nCols; ++idx)
        d_matrix[idx] = dist(gen);
    */
}