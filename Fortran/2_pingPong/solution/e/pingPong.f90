program pingPong
    use mpi
    implicit none

    ! Maximum array size 2^10 = 1024 elements
    integer, parameter :: MAX_ARRAY_SIZE = 2**10

    ! Variables for the process rank and number of processes
    integer :: myRank, numProcs, ierr
    integer, allocatable, dimension(:) :: myArray
    integer :: numberOfElementsToSend, numberOfElementsReceived
    integer, dimension(MPI_STATUS_SIZE) :: status
    real(kind=8) :: startTime, endTime
    integer :: messageSize

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

    ! Use a do while loop to vary the message size
    messageSize = 1
    do while (messageSize <= MAX_ARRAY_SIZE)
        if (myRank == 0) then
            numberOfElementsToSend = messageSize
            print '("Rank ",I2,": Sending ",I0," elements")', &
                myRank, numberOfElementsToSend

            ! Measure the time spent in MPI communication
            ! (use the variables startTime and endTime)
            startTime = MPI_WTIME()

            call MPI_SEND(myArray, numberOfElementsToSend, MPI_INTEGER, 1, 0, &
                MPI_COMM_WORLD, ierr)
            ! Probe message in order to obtain the amount of data
            call MPI_PROBE(1, 0, MPI_COMM_WORLD, &
                status, ierr)
            call MPI_GET_COUNT(status, MPI_INTEGER, numberOfElementsReceived, ierr)
            call MPI_RECV(myArray, numberOfElementsReceived, MPI_INTEGER, &
                status(MPI_SOURCE), status(MPI_TAG), &
                MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

            endTime = MPI_WTIME()

            print '("Rank ",I2,": Received ",I0," elements")', &
                myRank, numberOfElementsReceived

            print '("Ping Pong took ",F10.7," seconds")', endTime-startTime
        else if (myRank == 1) then
            ! Probe message in order to obtain the ammount of data
            call MPI_PROBE(0, 0, MPI_COMM_WORLD, &
                status, ierr)
            call MPI_GET_COUNT(status, MPI_INTEGER, numberOfElementsReceived, ierr)
            call MPI_RECV(myArray, numberOfElementsReceived, MPI_INTEGER, &
                status(MPI_SOURCE), status(MPI_TAG), &
                MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

            print '("Rank ",I2,": Received ",I0," elements")', &
                myRank, numberOfElementsReceived

            print '("Rank ",I2,": Sending back ",I0," elements")', &
                myRank, numberOfElementsToSend

            call MPI_SEND(myArray, numberOfElementsToSend, MPI_INTEGER, 0, 0, &
                MPI_COMM_WORLD, ierr)
        end if
        messageSize = messageSize * 2
    end do

    deallocate(myArray)

    ! Finalize MPI
    call MPI_FINALIZE(ierr)
end program pingPong
