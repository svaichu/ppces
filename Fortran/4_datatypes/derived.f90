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

    integer :: contigtype, vectortype
    integer :: numblocks, blocklength, stride

    integer, parameter :: matrix_dim = 10
    integer, dimension(matrix_dim, matrix_dim) :: matrix
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

        ! TODO: Create a vector type for sending columns

        call print_typeinfo(vectortype, "vector")
        call print_matrix(matrix, matrix_dim, myRank);

        ! TODO: Send 10 rows to rank 1

        ! TODO: Free type after use
    else
        ! TODO: Create a vector type for sending columns

        call print_typeinfo(contigtype, "contiguous")

        ! TODO: Receive 10 rows as columns from rank 0

        call print_matrix(matrix, matrix_dim, myRank)

        ! TODO: Free type after use
    endif

    call MPI_FINALIZE(ierr)

end program datatypes
