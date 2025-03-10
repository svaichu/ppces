program communicators

    use mpi
    integer :: ierr
    integer :: worldRank = -1, worldSize = -1
    integer :: dupRank = -1, dupSize = -1
    integer :: oddevenRank = -1, oddevenSize = -1
    integer :: upperlowerRank = -1, upperlowerSize = -1

    integer :: dupComm, oddevenComm, upperlowerComm
    integer :: color

    call MPI_INIT(ierr)

    call MPI_COMM_RANK(MPI_COMM_WORLD, worldRank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, worldSize, ierr)

    call MPI_COMM_DUP(MPI_COMM_WORLD, dupComm, ierr)
    call MPI_COMM_RANK(dupComm, dupRank, ierr)
    call MPI_COMM_SIZE(dupComm, dupSize, ierr)

    call MPI_COMM_SPLIT(MPI_COMM_WORLD, mod(worldRank, 2), &
            worldRank, oddevenComm, ierr)
    call MPI_COMM_RANK(oddevenComm, oddevenRank, ierr)
    call MPI_COMM_SIZE(oddevenComm, oddevenSize, ierr)

    if (worldRank < (worldSize / 2)) then
        color = 0
    else
        color = 1
    end if
    call MPI_COMM_SPLIT(MPI_COMM_WORLD, color, &
            worldSize - worldRank, upperlowerComm, ierr)
    call MPI_COMM_RANK(upperlowerComm, upperlowerRank, ierr)
    call MPI_COMM_SIZE(upperlowerComm, upperlowerSize, ierr)

    write (*, fmt="(4(a,i0,a,i0,a))") &
           "worldRank|Size: ", worldRank, "|", worldSize, " / ", &
           "dupRank|Size: ", dupRank, "|", dupSize, " / ", &
           "oddevenRank|Size: ", oddevenRank, "|", oddevenSize, " / ", &
           "upperlowerRank|Size: ", upperlowerRank, "|", upperlowerSize

    call MPI_COMM_FREE(dupComm, ierr)
    call MPI_COMM_FREE(oddevenComm, ierr)
    call MPI_COMM_FREE(upperlowerComm, ierr)

    call MPI_FINALIZE(ierr)

end program communicators
