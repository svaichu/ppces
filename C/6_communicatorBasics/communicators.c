#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

int main(int argc, char* argv[])
{
    int worldRank = -1, worldSize = -1;
    int dupRank = -1, dupSize = -1;
    int oddevenRank = -1, oddevenSize = -1;
    int upperlowerRank = -1, upperlowerSize = -1;

    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &worldRank);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSize);

    // TODO: Duplicate MPI_COMM_WORLD.
    //       Query rank and size in the new communicator.
    MPI_Comm dupComm = MPI_COMM_NULL;
    MPI_Comm_dup(MPI_COMM_WORLD, &dupComm);
    MPI_RANK_SIZE(dupComm, &dupSize);
    MPI_Comm_rank(dupComm, &dupRank);

    // TODO: Split MPI_COMM_WORLD into odd and even ranks in MPI_COMM_WORLD.
    //       Query rank and size in the new communicator.
    MPI_Comm evenComm = MPI_COMM_NULL;
    MPI_Comm oddComm = MPI_COMM_NULL;
    MPI_Comm_split(MPI_COMM_WORLD, worldRank % 2, worldRank, &evenComm);
    MPI_Comm_split(MPI_COMM_WORLD, worldRank % 2+1, worldRank, &oddComm);
    

    // TODO: Split MPI_COMM_WORLD into upper and lower halves an invert the rank order.
    //       Query rank and size in the new communicator.

    printf("WorldRank|Size: %d|%d / DupRank|Size: %d|%d / OddevenRank|Size: %d|%d / UpperLowerRank: %d|%d\n",
           worldRank, worldSize, dupRank, dupSize,
           oddevenRank, oddevenSize, upperlowerRank, upperlowerSize);
    fflush(stdout);

    MPI_Finalize();

    return EXIT_SUCCESS;
}