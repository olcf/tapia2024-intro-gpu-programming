program vector_addition
        use omp_lib
        use, intrinsic   :: iso_c_binding, only : c_loc,  c_size_t, c_sizeof, c_int
        implicit none
       
       integer,parameter :: N = 1048576
       integer           :: i
       real(8), allocatable :: A(:)
       real(8), allocatable :: B(:)
       real(8), allocatable :: C(:)
       DOUBLE PRECISION  :: byte, elapsed_time
       real(8) :: tolerance, start_time, end_time 
    
       !Allocating memory for A, B and C  
     !  allocate(A(n))  !
       allocate(A(N*sizeof(byte)))   !!to be consist with c code, we could allocate this way
       allocate(B(N))  !*sizeof(byte)))       !!but it still has N  dimensions
       allocate(C(N))  !*sizeof(byte)))
       
       !Initiatizing A, B and C
       do i=1,N
         A(i) = 1.0
         B(i) = 2.0
         C(i) = 0.0
       enddo
   
       !Summing arrays A and B for C
       start_time = omp_get_wtime()
       !$acc data copyin(A,B)    !!copying arrays A and B to device
       !$acc parallel loop
       do i=1,N

         C(i) = A(i) + B(i)
       enddo
       !$acc end data
       
       end_time = omp_get_wtime()
       elapsed_time = end_time - start_time

       !Verify results
       tolerance = 1.0d-14
       do i = 1, N
        if (abs(C(i) - 3.0d0) > tolerance) then
            print *, "Error: value of C(", i, ") = ", C(i), " instead of 3.0"
            stop 1
        end if
       end do
       
       ! Freeing up memory
       deallocate(A,B,C) 

       print *, ""
       print *, "---------------------------"
       print *, "__SUCCESS__"
       print *, "---------------------------"
       print *, "N                 = ", N
       print *, "---------------------------"
       print *, "Elapsed Compute Time           = ", elapsed_time
       print *, ""
     
end program

