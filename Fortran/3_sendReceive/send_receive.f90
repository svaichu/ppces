program sendReceive
    use mpi
    implicit none

    integer, parameter :: maxElements = 1048576

    integer :: myRank, numProcs, ierr
    integer, allocatable, dimension(:) :: data
    integer :: nextRank, prevRank, numElements
    integer, dimension(MPI_STATUS_SIZE) :: status

    allocate(data(maxElements))
    if (.not.allocated(data)) then
        print *,"Not enough memory"
        stop 1
    end if
    ! Note: Data remains uninitialized, as this is just an example

    ! MPI Initialization
    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)

    if (numProcs /= 2) then
        print *,"Error: This program can only run with 2 MPI tasks!"
        call MPI_ABORT(MPI_COMM_WORLD, 1, ierr)
        stop 1
    end if

    nextRank = mod(myRank+1, numProcs)
    prevRank = mod(myRank + numProcs - 1, numProcs)

    ! TODO: Remove the deadlock
    do numElements = 4096, maxElements, 4096
        print '("Process ",I0," sends ",I0," elements of data now")', &
            myRank, numElements
        call MPI_SEND(data, numElements, MPI_INTEGER, nextRank, 0, &
            MPI_COMM_WORLD, ierr)
        print '("Process ",I0," receives ",I0," elements of data now")', &
            myRank, numElements
        call MPI_RECV(data, numElements, MPI_INTEGER, prevRank, 0, &
            MPI_COMM_WORLD, status, ierr)
        print '("Process ",I0," is done with ",I0," elements of data")', &
            myRank, numElements
    end do

    deallocate(data)

    call MPI_FINALIZE(ierr)
end program sendReceive
