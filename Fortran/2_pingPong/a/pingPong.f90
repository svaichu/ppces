program pingPong
    use mpi
    implicit none

    ! Variables for the process rank and number of processes
    integer :: myRank, numProcs, ierr
    integer :: pingCount, pongCount

    pingCount = 42
    pongCount = 0

    ! TODO: Initialize MPI

    ! TODO: Find out MPI communicator size and process rank

    ! TODO: Have only the first process execute the following code
    if (    ) then
        print '("Sending Ping (# ",I0,")")', pingCount
        ! TODO: Send pingCount

        ! TODO: Receive pongCount

        print '("Received Pong (# ",I0,")")', pongCount
    else
        ! TODO: Do proper receive and send in other process

        ! TODO: Receive pingCount

        print '("Received Ping (# ",I0,")")', pingCount

        ! TODO: Calculate and send pongCount

        print '("Sending Pong (# ",I0,")")', pongCount
    end if

    ! TODO: Finialize MPI

end program pingPong
