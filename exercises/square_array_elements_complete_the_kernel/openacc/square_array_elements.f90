program vector_addition
        use omp_lib
        use, intrinsic   :: iso_c_binding, only : c_loc,  c_size_t, c_sizeof, c_int
        implicit none
       
       integer,parameter :: N = 1048576
       integer           :: i
       real(8), allocatable :: A(:)
       real(8), allocatable :: A_squared(:)
       DOUBLE PRECISION  :: byte
       real(8) :: tolerance, start_time, end_time
    
       !Allocating memory for A, B and C  
       allocate(A(N))  !(A(N*sizeof(byte)))   !!to be consist with c code, we could allocate this way
       allocate(A_squared(N))  !*sizeof(byte)))       !!but it still has N  dimensions
       
       
       !Initiatizing A, B and C
       do i=1,N
         A(i) = i
         A_squared(i) = 0.0
       enddo
       start_time= omp_get_wtime()
       !Squaring arrays A for A_squared
       !$acc parallel loop copyin(A) copyout(A_squared)
       do i=1,N

         !!TODO: Add in code for squaring A on the device
       enddo
 
       end_time=omp_get_wtime() - start_time

       !Verify results
       tolerance = 1.0d-14
       do i = 1, N
        if (abs(A_squared(i) - A(i) *A(i)) > tolerance) then
            print *, "Error: value of A_squared(", i, ") = ", A_squared(i), " instead of", A(i)*A(i)
            stop 1
        end if
       end do
       ! Freeing up memory
       deallocate(A,A_squared) 

       print *, ""
       print *, "---------------------------"
       print *, "__SUCCESS__"
       print *, "---------------------------"
       print *, "N                 = ", N
       print *, "Elapsed Time:                 = ", end_time
       print *, "---------------------------"
       print *, ""
     
end program



