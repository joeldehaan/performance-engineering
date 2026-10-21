#include <mpi.h>
#include <iostream>
#include <array>
#include <numeric>

using namespace std;

#ifndef NUM_BYTES
#define NUM_BYTES 1024
#endif

#ifndef REPEATS
#define REPEATS 4
#endif

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank;
    int size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    size_t tag = 0;         //the tag to communicate from

    size_t nSent = 0;
    array<unsigned char, NUM_BYTES> msg;

    if (rank == 0)      //initialise msg
    {
        iota(msg.begin(), msg.end(), 0);

        MPI_Send(msg.data(), NUM_BYTES, MPI_CHAR, rank + 1,      //rank 2 
                 tag, MPI_COMM_WORLD);
    }


    size_t const src = (rank - 1 + size) % size;
    size_t const dst = (rank + 1) % size;

    for (size_t i = 0; i < REPEATS; ++i) {
        MPI_Recv(msg.data(), NUM_BYTES, MPI_UNSIGNED_CHAR, src,
                 tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        MPI_Send(msg.data(), NUM_BYTES, MPI_UNSIGNED_CHAR, dst,
                 tag, MPI_COMM_WORLD);

        if (rank == 0)
            cerr << "Completed iteration " << i + 1 << '\n';
    }

    MPI_Finalize();


/*
    while (nSent != REPEATS)
    {
        MPI_Recv(msg.data(), NUM_BYTES, MPI_CHAR, (rank == 0 ? size - 1 : (rank - 1) % size),
                 tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Send(msg.data(), NUM_BYTES, MPI_CHAR, (rank + 1) % size,
                 tag, MPI_COMM_WORLD);

        cerr << "here\n";

        if (rank == 0)
            ++nSent;
    }

    MPI_Finalize();
*/
}