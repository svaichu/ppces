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

    ! PART C: Error message if too few processes
    if (numProcs < 2) then
        print *,"Error: Run the program with at least 2 MPI tasks!"
        call MPI_ABORT(MPI_COMM_WORLD, 1, ierr)
    end if

    ! TODO: Send the array with a single message and verify that you
    !       receive back the correct amount of data
    if (myRank == 0) then
        print '("Sending ",I0," elements")', numberOfElementsToSend
        ! Send numberOfElementsToSend elements
        call MPI_SEND(myArray, numberOfElementsToSend, MPI_INTEGER, 1, 0, &
            MPI_COMM_WORLD, ierr)
        ! Receive elements
        ! TODO: Determine the length of the messsage in advance
        numberOfElementsReceived = ...

        call MPI_RECV(myArray, numberOfElementsReceived, MPI_INTEGER, 1, 0, &
            MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

        print '("Received ",I0," elements")', numberOfElementsReceived
        ! Work even when processes are more than two
    else if (myRank == 1) then ! myRank == 1
        ! Receive the ping and send a pong
        ! TODO: Determine the length of the message in advance
        numberOfElementsReceived = ...

        call MPI_RECV(myArray, numberOfElementsReceived, MPI_INTEGER, 0, 0, &
            MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

        print '("Received ",I0," elements")', numberOfElementsReceived

        print '("Sending back ",I0," elements")', numberOfElementsToSend

        call MPI_SEND(myArray, numberOfElementsToSend, MPI_INTEGER, 0, 0, &
            MPI_COMM_WORLD, ierr)
    end if

    deallocate(myArray)

    ! Finalize MPI
    call MPI_FINALIZE(ierr)
end program pingPong
