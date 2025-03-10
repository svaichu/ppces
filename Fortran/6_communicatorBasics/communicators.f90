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

    ! TODO: Duplicate MPI_COMM_WORLD.
    !       Query rank and size in the new communicator

    ! TODO: Split MPI_COMM_WORLD into odd and even ranks in MPI_COMM_WORLD.
    !       Query rank and size in the new communicator.

    ! TODO: Split MPI_COMM_WORLD into upper and lower halves an invert the rank order.
    !       Query rank and size in the new communicator.

    write (*, fmt="(4(a,i0,a,i0,a))") &
           "worldRank|Size: ", worldRank, "|", worldSize, " / ", &
           "dupRank|Size: ", dupRank, "|", dupSize, " / ", &
           "oddevenRank|Size: ", oddevenRank, "|", oddevenSize, " / ", &
           "upperlowerRank|Size: ", upperlowerRank, "|", upperlowerSize

    call MPI_FINALIZE(ierr)

end program communicators
