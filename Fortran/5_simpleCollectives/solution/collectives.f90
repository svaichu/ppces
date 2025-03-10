module mycollectives
contains
    !
    ! Broadcasts 'count' elements of 'data' from rank 'root' to all
    ! other processes in the communicator 'comm'.
    !
    subroutine bcast_int(data, count, root, comm)
        use mpi
        implicit none
        integer, dimension(*), intent(inout) :: data
        integer, intent(in) :: count, root, comm

        integer :: myRank, numProcs, ierr, i

        call MPI_COMM_SIZE(comm, numProcs, ierr)
        call MPI_COMM_RANK(comm, myRank, ierr)
        if (myRank /= root) then
            call MPI_RECV(data, count, MPI_INTEGER, root, 0, comm, &
                MPI_STATUS_IGNORE, ierr)
        else
            do i = 0, numProcs-1
                if (i /= root) call MPI_SEND(data, count, MPI_INTEGER, i, 0, &
                    comm, ierr)
            end do
        end if
    end subroutine bcast_int

    !
    ! Scatters the content of 'sendbuf' in process with rank 'root' to
    ! all processes in the communicator 'comm'. Each piece of data is
    ! 'sendcnt' elements long. Received data goes into 'recvbuf'.
    !
    subroutine scatter_int(sendbuf, sendcnt, recvbuf, recvcnt, root, comm)
        use mpi
        implicit none
        integer, dimension(*), intent(in) :: sendbuf
        integer, intent(in) :: sendcnt
        integer, dimension(*), intent(out) :: recvbuf
        integer, intent(in) :: recvcnt, root, comm

        integer :: myRank, numProcs, ierr, i

        call MPI_COMM_SIZE(comm, numProcs, ierr)
        call MPI_COMM_RANK(comm, myRank, ierr)
        if (myRank /= root) then
            call MPI_RECV(recvbuf, recvcnt, MPI_INTEGER, root, 0, comm, &
                MPI_STATUS_IGNORE, ierr)
        else
            do i = 0, numProcs-1
                if (i /= root) then
                    call MPI_SEND(sendbuf(1+i*sendcnt), sendcnt, MPI_INTEGER, &
                        i, 0, comm, ierr)
                end if
            end do
            recvbuf(1:recvcnt) = sendbuf(1+root*recvcnt:(root+1)*recvcnt)
        end if
    end subroutine scatter_int

    !
    ! Gathers the content of each process' 'sendbuf' into the 'recvbuf'
    ! of process with rank 'root'. Each process sends 'sendcount' pieces
    ! of data and the root receives 'recvcnt' from each process.
    !
    subroutine gather_int(sendbuf, sendcnt, recvbuf, recvcnt, root, comm)
        use mpi
        implicit none
        integer, dimension(*), intent(in) :: sendbuf
        integer, intent(in) :: sendcnt
        integer, dimension(*), intent(out) :: recvbuf
        integer, intent(in) :: recvcnt, root, comm

        integer :: myRank, numProcs, ierr, i

        call MPI_COMM_SIZE(comm, numProcs, ierr)
        call MPI_COMM_RANK(comm, myRank, ierr)
        if (myRank /= root) then
            call MPI_SEND(sendbuf, sendcnt, MPI_INTEGER, root, 0, comm, ierr)
        else
            do i = 0, numProcs-1
                if (i /= root) then
                    call MPI_RECV(recvbuf(1+i*recvcnt), recvcnt, MPI_INTEGER, &
                        i, 0, comm, MPI_STATUS_IGNORE, ierr)
                end if
            end do
            recvbuf(1+root*recvcnt:(root+1)*recvcnt) = sendbuf(1:recvcnt)
        end if
    end subroutine gather_int

    !
    ! Scatters the content of each process' 'sendbuf' into the 'recvbuf'
    ! of each other process. Received pieces must be ordered by their
    ! sender's rank.
    !
    subroutine alltoall_int(sendbuf, sendcnt, recvbuf, recvcnt, comm)
        use mpi
        implicit none
        integer, dimension(*), intent(in) :: sendbuf
        integer, intent(in) :: sendcnt
        integer, dimension(*), intent(out) :: recvbuf
        integer, intent(in) :: recvcnt, comm

        integer :: myRank, numProcs, ierr, i, j

        call MPI_COMM_SIZE(comm, numProcs, ierr)
        call MPI_COMM_RANK(comm, myRank, ierr)
        do i = 0, numProcs-1
            if (i == myRank) then
                do j = 0, numProcs-1
                    if (i /= j) then
                        call MPI_SEND(sendbuf(1+j*sendcnt), sendcnt, MPI_INTEGER, &
                            j, 0, comm, ierr)
                    end if
                end do
                recvbuf(1+i*recvcnt:(i+1)*recvcnt) = &
                sendbuf(1+i*sendcnt:i*sendcnt+recvcnt)
            else
                call MPI_RECV(recvbuf(1+i*recvcnt), recvcnt, MPI_INTEGER, i, 0, &
                    comm, MPI_STATUS_IGNORE, ierr)
            end if
        end do
    end subroutine alltoall_int

    !
    ! Performs a global summation reduction over the single integer value
    ! in all processes' 'sendbuf'-s. The result should be available in
    ! 'recvbuf' only at process with rank 'root'.
    !
    subroutine sum_int(sendbuf, recvbuf, root, comm)
        use mpi
        implicit none
        integer, intent(in) :: sendbuf
        integer, intent(out) :: recvbuf
        integer, intent(in) :: root, comm

        integer :: myRank, numProcs, ierr, i, sum

        call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)
        call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)

        if (myRank == root) then
            sum = sendbuf
            do i = 2, numProcs
                call MPI_RECV(recvbuf, 1, MPI_INTEGER, MPI_ANY_SOURCE, 0, &
                    MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
                sum = sum + recvbuf
            end do
            recvbuf = sum
        else
            call MPI_SEND(sendbuf, 1, MPI_INTEGER, root, 0, MPI_COMM_WORLD, ierr)
        end if
    end subroutine sum_int

end module mycollectives

program collectives
    use mpi
    use mycollectives
    implicit none
    integer :: myRank, numProcs, ierr
    integer :: i, myRandomNumber
    integer :: inspectRank = 0
    integer, dimension(:), allocatable :: mySendBuffer, myRecvBuffer
    integer, dimension(1) :: myData
    character(len=128) :: cmdArg
    character(len=40) :: fmt

    ! Variable to generate random number
    real(KIND=4) :: randomReal

    call MPI_INIT(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)

    ! Allocate data buffers
    allocate(mySendBuffer(numProcs))
    allocate(myRecvBuffer(numProcs))

    ! Seed the random number generator with a rank-specific value
    call random_seed()
    call random_number(randomReal)
    myRandomNumber =  floor( randomReal * 100.0 )

    if (iargc() > 0) then
        call getarg(1, cmdArg)
        read(cmdArg,*) inspectRank
        if (inspectRank < 0 .or. inspectRank >= numProcs) &
            call MPI_ABORT(MPI_COMM_WORLD, 1, ierr)
    end if

    print '("Rank ",I2.1," has the random number ",I0)', myRank, myRandomNumber

    myData = -1

    ! Use MPI barrier to synchronize the output
    call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! ---- Broadcast operation ----

    if (myRank == inspectRank) print '(A,/,A,/,A)', &
        "-------------------------------------", &
        "broadcast", &
        "-------------------------------------"

    ! Prepare the local data
    myData = myRandomNumber

    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData before the broadcast is ", myData

    ! Call the user's implementation of broadcast
    call bcast_int(myData, 1, 0, MPI_COMM_WORLD)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the broadcast is ", myData

    ! Call the MPI broadcast implementation
    call MPI_BCAST(myData, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the MPI broadcast is ", myData

    call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! ---- Scatter operation ----

    if (myRank == inspectRank) print '(A,/,A,/,A)', &
        "-------------------------------------", &
        "scatter", &
        "-------------------------------------"

    ! Prepare the local data. Mark each random number with a prefix
    ! accord to its position in the send buffer
    mySendBuffer = (/(myRandomNumber + i*100, i = 0, numProcs-1)/)
    myData = -1

    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData before the scatter is ", myData

    ! Call the user's implementation of scatter
    call scatter_int(mySendBuffer, 1, myData, 1, 0, MPI_COMM_WORLD)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the scatter is ", myData

    ! Call the MPI scatter implementation
    call MPI_SCATTER(mySendBuffer, 1, MPI_INTEGER, myData, 1, MPI_INTEGER, &
        0, MPI_COMM_WORLD, ierr)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the MPI scatter is ", myData

    call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! ---- Gather operation ----

    if (myRank == inspectRank) print '(A,/,A,/,A)', &
        "-------------------------------------", &
        "gather", &
        "-------------------------------------"

    ! Prepare the local data
    myRecvBuffer = -1
    myData = myRandomNumber
    write (fmt, *) numProcs
    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer before the gather is ", &
        (myRecvBuffer(i), i=1, numProcs)

    ! Call the user's implementation of gather
    call gather_int(myData, 1, myRecvBuffer, 1, 0, MPI_COMM_WORLD)
    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer after the gather is ", &
        (myRecvBuffer(i), i=1, numProcs)

    ! Call the MPI gather implementation
    call MPI_GATHER(myData, 1, MPI_INTEGER, myRecvBuffer, 1, MPI_INTEGER, &
        0, MPI_COMM_WORLD, ierr)

    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer after the MPI gather is ", &
        (myRecvBuffer(i), i=1, numProcs)


    call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! ---- All-to-all operation ----

    if (myRank == inspectRank) print '(A,/,A,/,A)', &
        "-------------------------------------", &
        "all-to-all", &
        "-------------------------------------"

    ! Prepare the local data
    mySendBuffer = (/(myRandomNumber + i*100, i = 0, numProcs-1)/)
    myRecvBuffer = -1

    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer before the all-to-all is ", &
        (myRecvBuffer(i), i=1, numProcs)

    ! Call the user's implementation of all-to-all
    call alltoall_int(mySendBuffer, 1, myRecvBuffer, 1, MPI_COMM_WORLD)
    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer after the all-to-all is ", &
        (myRecvBuffer(i), i=1, numProcs)

    ! Call the MPI all-to-all implementation
    call MPI_ALLTOALL(mySendBuffer, 1, MPI_INTEGER, &
        myRecvBuffer, 1, MPI_INTEGER, MPI_COMM_WORLD, ierr)

    if (myRank == inspectRank) print '(A,I2.1,A,'// ADJUSTL(fmt) //'(" ",I0))', &
        "Rank ", inspectRank, ": myRecvBuffer after the MPI all-to-all is", &
        (myRecvBuffer(i), i=1, numProcs)

    call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! ---- Gloal reduction operation ----

    if (myRank == inspectRank) print '(A,/,A,/,A)', &
        "-------------------------------------", &
        "reduce", &
        "-------------------------------------"

    ! Prepare the local data
    myData = -1

    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData before the reduction is ", myData

    ! Call the user's implementation of global reduction to sum all ranks
    call sum_int(myRank, myData(1), 0, MPI_COMM_WORLD)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the reduction is ", myData

    call MPI_REDUCE(myRank, myData(1), 1, MPI_INTEGER, MPI_SUM, 0, &
        MPI_COMM_WORLD, ierr)
    if (myRank == inspectRank) print '(A,I2.1,A,I0)', &
        "Rank ", inspectRank, ": myData after the MPI reduction is ", myData

    call MPI_FINALIZE(ierr)
end program collectives
