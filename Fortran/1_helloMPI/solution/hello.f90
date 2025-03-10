program hello
    ! TODO: Make the MPI functions and constants available
    use mpi
    integer :: ierr, numProcs, rank 
    ! TODO: Initialise the MPI library
    call MPI_INIT(ierr)
    ! TODO: Obtain the process ID and the number of processes
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)
    ! TODO: Display the process ID and the number of processes
    write(*, fmt="(a, i2, a, i2, a)") "Hello world from rank ", rank, " of ", numProcs, " in communicator MPI_COMM_WORLD."

    ! TODO: Finalize the MPI library
    call MPI_FINALIZE(ierr)
end program hello
