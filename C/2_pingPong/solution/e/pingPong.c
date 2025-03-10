#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

// Maximum array size 2^26 = 67108864 elements
#define MAX_ARRAY_SIZE (1<<26)

int main(int argc, char **argv)
{
    // Variables for the process rank and number of processes
    int worldRank, worldSize;
    MPI_Status status;

    // Initialize MPI, find out MPI communicator size and process rank
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);
    MPI_Comm_rank(MPI_COMM_WORLD, &worldRank);


    int *myArray = (int *)malloc(sizeof(int)*MAX_ARRAY_SIZE);
    if (myArray == NULL)
    {
        printf("Not enough memory\n");
        exit(1);
    }
    int numberOfElementsToSend;
    int numberOfElementsReceived;

    // PART C
    if (worldSize < 2)
    {
        printf("Error: Run the program with at least 2 MPI tasks!\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    int messageSize;

    // Use a loop to vary the message size
    for (messageSize = 1; messageSize <= MAX_ARRAY_SIZE; messageSize <<= 1)
    {
        if (worldRank == 0)
        {
            double startTime, endTime;

            numberOfElementsToSend = messageSize;
            printf("Rank %2.1i: Sending %i elements\n",
                worldRank, numberOfElementsToSend);

            // Measure the time spent in MPI communication
            // (use the variables startTime and endTime)
            startTime = MPI_Wtime();

            MPI_Send(myArray, numberOfElementsToSend, MPI_INT, 1, 0,
                MPI_COMM_WORLD);
            // Probe message in order to obtain the amount of data
            MPI_Probe(1, 0, MPI_COMM_WORLD, &status);
            MPI_Get_count(&status, MPI_INT, &numberOfElementsReceived);
            MPI_Recv(myArray, numberOfElementsReceived, MPI_INT,
                     status.MPI_SOURCE, status.MPI_TAG,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            endTime = MPI_Wtime();

            printf("Rank %2.1i: Received %i elements\n",
                worldRank, numberOfElementsReceived);

            printf("Ping Pong took %f seconds\n", endTime - startTime);
        }
        else if (worldRank == 1)
        {
            // Probe message in order to obtain the amount of data
            MPI_Probe(0, 0, MPI_COMM_WORLD, &status);
            MPI_Get_count(&status, MPI_INT, &numberOfElementsReceived);
            MPI_Recv(myArray, numberOfElementsReceived, MPI_INT,
                     status.MPI_SOURCE, status.MPI_TAG,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            printf("Rank %2.1i: Received %i elements\n",
                worldRank, numberOfElementsReceived);

            numberOfElementsToSend = numberOfElementsReceived;

            printf("Rank %2.1i: Sending back %i elements\n",
                worldRank, numberOfElementsToSend);

            MPI_Send(myArray, numberOfElementsToSend, MPI_INT, 0, 0,
                MPI_COMM_WORLD);
        }
    }

    // Finalize MPI
    MPI_Finalize();

    return 0;
}
