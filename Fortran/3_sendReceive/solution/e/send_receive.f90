program sendReceive
    use mpi
    implicit none

    integer, parameter :: maxElements = 1048576

    integer :: myRank, numProcs, ierr
    integer, allocatable, dimension(:) :: data, tmpdata
    integer :: nextRank, prevRank, numElements
    integer, dimension(MPI_STATUS_SIZE) :: status
    integer :: request

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

    if (numProcs < 2) then
        print *,"Error: This program needs at least 2 MPI tasks!"
        call MPI_ABORT(MPI_COMM_WORLD, 1, ierr)
        stop 1
    end if

    nextRank = mod(myRank+1, numProcs)
    prevRank = mod(myRank-1+numProcs, numProcs)

    do numElements = 4096, maxElements, 4096
        print '("Process ",I0," shifts ",I0," elements now")', &
            myRank, numElements
        call MPI_SENDRECV(data, numElements, MPI_INTEGER, nextRank, 0, &
            tmpdata, numElements, MPI_INTEGER, prevRank, 0, &
            MPI_COMM_WORLD, status, ierr)
        print '("Process ",I0," shifts back ",I0," elements of data now")', &
            myRank, numElements
        call MPI_SENDRECV(tmpdata, numElements, MPI_INTEGER, prevRank, 0, &
            data, numElements, MPI_INTEGER, nextRank, 0, &
            MPI_COMM_WORLD, status, ierr)
        print '("Process ",I0," is done with ",I0," elements of data")', &
            myRank, numElements
    end do

    deallocate(data)
    deallocate(tmpdata)

    call MPI_FINALIZE(ierr)
end program sendReceive
