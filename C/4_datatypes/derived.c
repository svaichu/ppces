#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

const int MATRIX_DIM = 10;

#define INITIALIZE_MATRIX(matrix, size, expr) \
    for (int i = 0; i < size; i++) \
        for( int j = 0; j < size; j++) \
            matrix[i * size + j] = expr;

void print_matrix(int* matrix, int size)
{
    for (int i = 0; i < size; i++)
    {
        for( int j = 0; j < size; j++)
        {
            printf("%3i ", matrix[i*size+j]);
        }
        printf("\n");
    }
}

void print_typeinfo(MPI_Datatype type, const char* typename)
{
    int size;
    MPI_Aint lb, extent;
    MPI_Type_size(type, &size);
    MPI_Type_get_extent(type, &lb, &extent);
    printf("%s: size=%d, lb=%ld, extent=%ld\n", typename, size, lb, extent);
}

int main(int argc, char** argv)
{
    int my_rank, num_ranks, tag = 0;
    MPI_Datatype dtype;

    int* matrix = calloc(MATRIX_DIM*MATRIX_DIM, sizeof(int));

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_ranks);

    if (my_rank == 0)
    {
        INITIALIZE_MATRIX(matrix, MATRIX_DIM, i*100+j);
    }
    else
    {
        INITIALIZE_MATRIX(matrix, MATRIX_DIM, 0);
    }

    if (my_rank == 0)
    {
        // TODO: Create a vector type for sending columns
        MPI_Type_vector(MATRIX_DIM, 1, MATRIX_DIM, MPI_INT, &dtype);
        MPI_Type_commit(&dtype);

        print_typeinfo(dtype, "vector");
        print_matrix(matrix, MATRIX_DIM);

        // TODO: Send 10 columns to rank 1
        for (int i = 0; i < 10; i++)
            MPI_Send(&matrix[i], 1, dtype, 1, tag, MPI_COMM_WORLD);    

        // TODO: Free type after use
        MPI_Type_free(&dtype);
    }
    else
    {
        // TODO: Create a contiguous type for receiving columns (as rows)
        MPI_Type_contiguous(MATRIX_DIM, MPI_INT, &dtype);
        MPI_Type_commit(&dtype);

        // TODO: Receive 10 columns as rows from rank 0
        for (int i = 0; i < 10; i++)
            MPI_Recv(&matrix[i

        print_typeinfo(dtype, "contiguous");
        print_matrix(matrix, MATRIX_DIM);

        // TODO: Free type after use
    }

    MPI_Finalize();

    return EXIT_SUCCESS;
}
