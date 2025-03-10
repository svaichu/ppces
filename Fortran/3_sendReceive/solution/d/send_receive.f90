program sendReceive
    use mpi
    implicit none

    integer, parameter :: maxElements = 1048576

    integer :: myRank, numProcs, ierr
    integer, allocatable, dimension(:) :: data, tmpdata
    integer :: nextRank, prevRank, numElements
    integer :: requests(2)

    allocate(data(maxElements))
    allocate(tmpdata(maxElements))
    if (.not.allocated(data) .or. .not.allocated(tmpdata)) then
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
    prevRank = mod(myRank-1+numProcs, numProcs)

    do numElements = 4096, maxElements, 4096
        print '("Process ",I0," sends ",I0," elements of data now")', &
            myRank, numElements
        call MPI_ISEND(data, numElements, MPI_INTEGER, nextRank, 0, &
            MPI_COMM_WORLD, requests(1), ierr)
        print '("Process ",I0," receives ",I0," elements of data now")', &
            myRank, numElements
        ! Cannot use data to receive messages since it might still be in use
        ! by the sending operation. That's why we use a temporary buffer.
        call MPI_IRECV(tmpdata, numElements, MPI_INTEGER, MPI_ANY_SOURCE, 0, &
            MPI_COMM_WORLD, requests(2), ierr)
        call MPI_WAITALL(2, requests, MPI_STATUSES_IGNORE, ierr)
        ! Copy the temporary receive buffer to data
        data(1:numElements) = tmpdata(1:numElements)
        print '("Process ",I0," is done with ",I0," elements of data")', &
            myRank, numElements
    end do

    deallocate(data)

    call MPI_FINALIZE(ierr)
end program sendReceive
