program stencil
    use omp_lib
    implicit none
    integer, parameter :: N = 64 * 1024 * 1024
    integer, parameter :: stencil_radius = 3
    integer, parameter :: stencil_size = 2 * stencil_radius + 1
    integer, parameter :: total_time_steps = 10
    integer, parameter :: halo_size = N + 2 * stencil_radius
    real(8), dimension(:), allocatable :: A, A_average_cpu, A_average_gpu
    integer :: i, j, time_step
    real(8) :: total_start, total_stop
    real(8) :: cpu_start, cpu_stop, gpu_start, gpu_stop
    real(8) :: elapsed_time_cpu_compute = 0.0
    real(8) :: elapsed_time_gpu_compute = 0.0
    real(8) :: tolerance
    integer :: seed

    ! Seed for random number generation
    seed = 123456789
    call random_seed(seed)

    ! Allocate memory
    allocate(A(halo_size))
    allocate(A_average_cpu(halo_size))
    allocate(A_average_gpu(halo_size))

    ! Fill array A with random numbers
    call random_number(A)
    
    ! Start timer for total time
    total_start = omp_get_wtime()

    do time_step = 1, total_time_steps

        ! Start timer for CPU calculations
        cpu_start = omp_get_wtime()

        ! Average values of array elements on the host (CPU) - excluding halo
        !$omp parallel do
        do i = stencil_radius + 1, stencil_radius + N
            if (i >= stencil_radius + 1 .and. i < stencil_radius + N + 1) then
                A_average_cpu(i) = 0.0
                do j = -stencil_radius, stencil_radius
                    A_average_cpu(i) = A_average_cpu(i) + A(i + j)
                end do
                A_average_cpu(i) = A_average_cpu(i) / stencil_size
            end if
        end do

        ! Stop timer for CPU calculations
        cpu_stop = omp_get_wtime()
        elapsed_time_cpu_compute = elapsed_time_cpu_compute + cpu_stop - cpu_start

        
        gpu_start = omp_get_wtime()

        ! Perform computation on GPU
        !!TODO : write code to move data from host to device for target region
        !$acc parallel loop copyin(A) copyout(A_average_gpu) private(i,j)
        do i = stencil_radius + 1, stencil_radius + N
            if (i >= stencil_radius + 1 .and. i < stencil_radius + N + 1) then
                A_average_gpu(i) = 0.0
                ! !$acc parallel loop private(j)
                do j = -stencil_radius, stencil_radius
                    !$acc atomic update
                    A_average_gpu(i) = A_average_gpu(i) + A(i + j)
                end do
                !$acc atomic update
                A_average_gpu(i) = A_average_gpu(i) / stencil_size
            end if
        end do
        ! Stop timer for GPU calculations
        gpu_stop = omp_get_wtime()
        elapsed_time_gpu_compute = elapsed_time_gpu_compute + gpu_stop - gpu_start

    end do
    
    ! Stop timer for total time
    total_stop = omp_get_wtime()

    ! Verify results - ignoring the halo at start and end of main array
    tolerance = 1.0e-14
    do i = stencil_radius + 1, stencil_radius + N
        if (abs(A_average_cpu(i) - A_average_gpu(i)) > tolerance) then
            print *, "Error: value of A_average_gpu(", i, ") = ", A_average_gpu(i), " instead of ", A_average_cpu(i)
            stop
        end if
    end do

    ! Free memory
    deallocate(A)
    deallocate(A_average_cpu)
    deallocate(A_average_gpu)

    print *, "-----------------------------------------------"
    print *, "__SUCCESS__"
    print *, "-----------------------------------------------"
    print *, "Number of Array Elements           = ", N
    print *, "Number of Bytes in Array (MB)      = ", halo_size * 8 / (1024 * 1024)
    print *, "Number of Time Steps               = ", total_time_steps
    print *, "Elapsed CPU Compute Time (s)       = ", elapsed_time_cpu_compute
    print *, "Elapsed GPU Compute Time (s)       = ", elapsed_time_gpu_compute
    print *, "Elapsed Time Total (s)             = ", total_stop - total_start
    print *, "-----------------------------------------------"
    print *, ""

end program stencil

