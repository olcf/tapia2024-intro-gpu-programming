program vector_addition
        use omp_lib
        use, intrinsic   :: iso_c_binding, only : c_loc,  c_size_t, c_sizeof, c_int
        implicit none
       
       integer,parameter :: N = 1048576
       integer           :: i
       real(8), allocatable :: A(:)
       real(8), allocatable :: B(:)
       real(8), allocatable :: C(:)
       DOUBLE PRECISION  :: byte
       real(8) :: tolerance, start_time, end_time
    
       !Allocating memory for A, B and C  
       allocate(A(n))  !(A(N*sizeof(byte)))   !!to be consist with c code, we could allocate this way
       allocate(B(N))  !*sizeof(byte)))       !!but it still has N  dimensions
       allocate(C(N))  !*sizeof(byte)))
       
       !Initiatizing A, B and C
       do i=1,N
         A(i) = 1.0
         B(i) = 2.0
         C(i) = 0.0
       enddo
       start_time= omp_get_wtime()
       !Summing arrays A and B for C
       !$acc parallel loop copyin(A,B) 
       do i=1,N

         C(i) = A(i) + B(i)
       enddo
 
       end_time=omp_get_wtime() - start_time
       ! Freeing up memory
       deallocate(A,B,C) 

       print *, ""
       print *, "---------------------------"
       print *, "__SUCCESS__"
       print *, "---------------------------"
       print *, "N                 = ", N
       print *, "Elapsed Time:                 = ", end_time
       print *, "---------------------------"
       print *, ""
     
end program

