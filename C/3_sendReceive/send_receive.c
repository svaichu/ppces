#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

int main(int argc, char **argv)
{
    int maxElements = 1048576;

    int *data = (int *)malloc(sizeof(int) * maxElements);
    if (data == NULL)
    {
        printf("Not enough memory\n");
        return -1;
    }
    else
    {
        // Initialize with random data for this example
        srand(42);
        for (int i = 0; i < maxElements; ++i)
        {
            data[i] = rand();
        }
    }

    int worldRank, worldSize;
    // MPI Initialization
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);
    MPI_Comm_rank(MPI_COMM_WORLD, &worldRank);

    if (worldSize != 2)
    {
        printf("This program can only be started with 2 MPI processes\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
        return 1;
    }

    int nextRank = (worldRank + 1) % worldSize;
    int prevRank = (worldRank - 1 + worldSize) % worldSize;
    int numElements;

    // TODO: Remove the deadlock
    for (numElements = 4096; numElements < maxElements; numElements += 4096)
    {
        MPI_Status status;
        MPI_Request request;

        printf("Rank %i sends %i elements of data now\n",
            worldRank, numElements);
        MPI_Isend(data, numElements, MPI_INT, nextRank, 0, MPI_COMM_WORLD, &request);

        printf("Rank %i receives %i elements of data now\n",
            worldRank, numElements);
        MPI_Irecv(data, numElements, MPI_INT, prevRank, 0,
            MPI_COMM_WORLD, &request);

        printf("Rank %i is done with %i elements of data\n",
            worldRank, numElements);
        
        MPI_Wait(&request, &status);
    }

    MPI_Finalize();
    return 0;
}
