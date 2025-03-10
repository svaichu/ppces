program pingPong
    use mpi
    implicit none

    ! Variables for the process rank and number of processes
    integer :: myRank, numProcs, ierr
    integer :: pingCount, pongCount

    pingCount = 42
    pongCount = 0

    ! Initialize MPI
    call MPI_INIT(ierr)

    ! Find out MPI communicator size and process rank
    call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)

    ! Have only the first process execute the following code
    if (myRank == 0) then
        print '("Sending Ping (# ",I0,")")', pingCount
        ! Send pingCount
        call MPI_SEND(pingCount, 1, MPI_INTEGER, 1, 0, &
            MPI_COMM_WORLD, ierr)

        ! Receive pongCount
        call MPI_RECV(pongCount, 1, MPI_INTEGER, 1, 0, &
            MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
        
        print '("Received Pong (# ",I0,")")', pongCount
    else
        ! Do proper receive and send in other process

        ! Receive pingCount
        call MPI_RECV(pingCount, 1, MPI_INTEGER, 0, 0, &
            MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

        print '("Received Ping (# ",I0,")")', pingCount

        ! Calculate and send pongCount
        pongCount = -pingCount
        call MPI_SEND(pongCount, 1, MPI_INTEGER, 0, 0, &
            MPI_COMM_WORLD, ierr)

        print '("Sending Pong (# ",I0,")")', pongCount
    end if

    ! Finialize MPI
    call MPI_FINALIZE(ierr)

end program pingPong
