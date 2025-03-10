#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char **argv)
{
    int worldRank, worldSize;
    int pingCount = 42;
    int pongCount = 0;

    // Initialize MPI
    MPI_Init(&argc, &argv);

    // Find out MPI communicator size and process rank
    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);

    // TODO: Have only the first process execute the following code
    if (worldRank == 0)
    {
        printf("Sending Ping (# %i)\n", pingCount);
        // Send pingCount
        MPI_Send(&pingCount, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);

        // Receive pongCount
        MPI_Recv(&pongCount, 1, MPI_INT, 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        
        printf("Received Pong (# %i)\n", pongCount);
    }
    // Do proper receive and send in other process
    else
    {
        // TODO: Receive pingCount
        MPI_Recv(&pingCount, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        printf("Received Ping (# %i)\n", pingCount);

        // TODO: calculate and send pongCount
        printf("Sending Pong (# %i)\n", pongCount);

    }

    // TODO: Finalize MPI
    MPI_Finalize();

    return EXIT_SUCCESS;
}
