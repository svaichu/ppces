program pingPong
    use mpi

    implicit none

    ! Maximum array size 2^10 = 1024 elements
    integer, parameter :: MAX_ARRAY_SIZE = 2**10

    ! Variables for the process rank and number of processes
    integer :: myRank, numProcs, ierr
    integer, allocatable, dimension(:) :: myArray
    integer :: numberOfElementsToSend, numberOfElementsReceived

    ! Variables to generate random number
    real(KIND=4) :: randomReal

    ! Initialize MPI
    call MPI_INIT(ierr)
    ! Find out MPI communicator size and process rank
    call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)

    ! PART B
    call random_seed()
    call random_number(randomReal)
    numberOfElementsToSend =  floor( randomReal * 100.0 )

    ! Allocate an array big enough to hold even the largest message
    allocate(myArray(MAX_ARRAY_SIZE))
    if (.not.allocated(myArray)) then
        print *,"Not enough memory"
        stop 1
    end if

    ! Have only the first process execute the following code
    if (myRank == 0) then
        print '("Sending ",I0," elements")', numberOfElementsToSend
        ! TODO: Send "numberOfElementsToSend" elements

        ! TODO: Receive elements

        ! TODO: Store number of elements received in numberOfElementsReceived

        print '("Received ",I0," elements")', numberOfElementsReceived
    else
        ! TODO: Receive elements

        ! TODO: Store number of elements received in numberOfElementsReceived

        print '("Received ",I0," elements")', numberOfElementsReceived

        print '("Sending back ",I0," elements")', numberOfElementsToSend

        ! TODO: Send "numberOfElementsToSend" elements

    end if

    deallocate(myArray)
    ! Finalize MPI
    call MPI_FINALIZE(ierr)
end program pingPong
