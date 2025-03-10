module print_helpers
    contains

    subroutine print_typeinfo(datatype, typename)
        use mpi
        implicit none
        integer :: datatype
        character*(*) :: typename

        integer ierr, typesize
        integer(KIND=MPI_ADDRESS_KIND) :: lb, extent

        call MPI_TYPE_SIZE(datatype, typesize, ierr)
        call MPI_TYPE_GET_EXTENT(datatype, lb, extent, ierr)

        write (*, fmt="(a,3(a,i0))") typename, ": size=", typesize, " lb=", &
                lb, ", extent=", extent
    end subroutine print_typeinfo

    subroutine print_matrix(matrix, matrix_dim, rank)
        implicit none
        character(len=40) :: fmt
        integer :: matrix_dim, i, rank
        integer, dimension(matrix_dim,matrix_dim) :: matrix

        write (fmt, *) '(i1,a,', matrix_dim, '(" ",i3))'

        do i = 1, matrix_dim
            write (*,fmt) rank, ":", matrix(i,:)
        end do
    end subroutine

end module print_helpers

program datatypes

    use mpi
    use print_helpers
    implicit none

    integer :: i,j
    integer :: ierr, myRank, numProcs, tag = 0
    integer, dimension(MPI_STATUS_SIZE) :: status

    integer, parameter :: matrix_dim = 10
    integer, dimension(matrix_dim, matrix_dim) :: matrix

    integer :: vectortype, matrixtype
    integer :: numblocks, blocklength, stride, intsize
    integer, dimension(matrix_dim) :: blocklengths
    integer(KIND=MPI_ADDRESS_KIND), dimension(matrix_dim) :: displs

    character(len=40) :: fmt
    write (fmt, *) '(i1,a,', matrix_dim, '(" ",i3))'

    call MPI_INIT(ierr)

    call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numProcs, ierr)

    if (myRank .eq. 0) then
        do i = 1, matrix_dim
            do j = 1, matrix_dim
                matrix(j,i) = (j-1)*100 + i
            end do
        end do
    else
        do i = 1, matrix_dim
            do j = 1, matrix_dim
                matrix(j,i) = -1
            end do
        end do
    end if

    if (myRank .eq. 0) then
        numblocks = matrix_dim
        blocklength = 1
        stride = matrix_dim

        call MPI_TYPE_VECTOR(numblocks, blocklength, stride, &
                MPI_INTEGER, vectortype, ierr)

        call MPI_TYPE_SIZE(MPI_INTEGER, intsize, ierr)
        blocklengths = (/ (1, i=1, matrix_dim) /)
        displs = (/ (i*intsize, i=0, matrix_dim-1) /)
        call MPI_TYPE_CREATE_HINDEXED(matrix_dim, blocklengths, displs, &
                vectortype, matrixtype, ierr)
        call MPI_TYPE_COMMIT(matrixtype, ierr)

        call print_typeinfo(matrixtype, "vector matrixtype")
        call print_matrix(matrix, matrix_dim, myRank);

        call MPI_SEND(matrix, 1, matrixtype, 1, tag, MPI_COMM_WORLD, ierr)

        call MPI_TYPE_FREE(vectortype, ierr)
        call MPI_TYPE_FREE(matrixtype, ierr)
    else if (myRank .eq. 1) then
        call MPI_TYPE_CONTIGUOUS(matrix_dim * matrix_dim, MPI_INTEGER, matrixtype, ierr)
        call MPI_TYPE_COMMIT(matrixtype, ierr)

        call print_typeinfo(matrixtype, "contiguous matrixtype")

        call MPI_RECV(matrix, 1, matrixtype, 0, tag, MPI_COMM_WORLD, status, ierr)
        call print_matrix(matrix, matrix_dim, myRank)

        call MPI_TYPE_FREE(matrixtype, ierr)
    endif

    call MPI_FINALIZE(ierr)

end program datatypes
