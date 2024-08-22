#include "hip/hip_runtime.h"
#include <stdio.h>
#include <omp.h>

/* ============================================================== */
/* Macro for checking errors in GPU API calls                     */
/* ============================================================== */
#define gpuErrorCheck(call)                                                                 \
do{                                                                                         \
    hipError_t gpuErr = call;                                                               \
    if(hipSuccess != gpuErr){                                                               \
        printf("GPU Error - %s:%d: '%s'\n", __FILE__, __LINE__, hipGetErrorString(gpuErr)); \
        exit(1);                                                                            \
    }                                                                                       \
}while(0)

/* ============================================================== */
/* Define Problem Values                                          */
/* ============================================================== */

// Size of array
#define N (64 * 1024 * 1024)

// Stencil values
#define stencil_radius 3
#define stencil_size (2 * stencil_radius + 1)

// Number of threads in each block
#define threads_per_block 128

// Number of time steps
#define total_time_steps 10

/* ============================================================== */
/* Kernel                                                         */
/* ============================================================== */
__global__ void average_array_elements(double *a, double *a_average)
{
    int id = blockDim.x * blockIdx.x + threadIdx.x + stencil_radius;

    // If id is not in the halo...
    if( id >= (stencil_radius) && id < (N + stencil_radius)){
        // Calculate sum of stencil elements
        double sum = 0.0;
        for(int j=-stencil_radius; j<=stencil_radius; j++){
            sum = sum + a[id + j];
        }

        // Use sum to find average and store it in a_average.
        a_average[id] = sum / stencil_size;
    }
}

/* ============================================================== */
/* Main program                                                   */
/* ============================================================== */
int main()
{
    // Number of bytes to allocate for N + 2*stencil_radius array elements
    size_t bytes = (N + 2*stencil_radius)*sizeof(double);

    // Allocate memory for arrays A, A_average_cpu, A_average_gpu on host
    double *A             = (double*)malloc(bytes);
    double *A_average_cpu = (double*)malloc(bytes);
    double *A_average_gpu = (double*)malloc(bytes);

    // Initialize the GPU with a dummy API call
    gpuErrorCheck( hipFree(NULL) );

    // Allocate memory for arrays d_A, d_A_average on device
    double *d_A, *d_A_average;
    gpuErrorCheck( hipMalloc(&d_A, bytes) );	
    gpuErrorCheck( hipMalloc(&d_A_average, bytes) );

    // Fill host array A with random numbers on host
    for(int i=0; i<(N+2*stencil_radius); i++)
    {
        A[i] = (double)rand()/(double)RAND_MAX;
    }

    // Set execution configuration parameters
    //      thr_per_blk: number of GPU threads per grid block
    //      blk_in_grid: number of blocks in grid
    int thr_per_blk = threads_per_block;
    int blk_in_grid = ceil( float(N+2*stencil_radius) / thr_per_blk );

    // Create GPU start/stop event objects and declare timing variables
    hipEvent_t gpu_start, gpu_stop;
    gpuErrorCheck( hipEventCreate(&gpu_start) );
    gpuErrorCheck( hipEventCreate(&gpu_stop) );

    double total_start, total_stop;
    double cpu_start, cpu_stop;
    double elapsed_time_cpu_compute        = 0.0;
    float  elapsed_time_gpu_compute_temp;
    float  elapsed_time_gpu_compute        = 0.0;
    float  elapsed_time_gpu_data_transfers_temp;
    float  elapsed_time_gpu_data_transfers = 0.0;

    // Start timer for total time
    total_start = omp_get_wtime();

    // Start timer for GPU H2D data transfer
    gpuErrorCheck( hipEventRecord(gpu_start, NULL) );

    // Copy data from host array A to device array d_A
    gpuErrorCheck( hipMemcpy(d_A, A, bytes, hipMemcpyHostToDevice) );

    // Stop timer for GPU H2D data transfer
    gpuErrorCheck( hipEventRecord(gpu_stop, NULL) );
    gpuErrorCheck( hipEventSynchronize(gpu_stop) );
    gpuErrorCheck( hipEventElapsedTime(&elapsed_time_gpu_data_transfers_temp, gpu_start, gpu_stop) );
    elapsed_time_gpu_data_transfers += elapsed_time_gpu_data_transfers_temp;

    // Time step loop
    for(int time_step = 0; time_step < total_time_steps; time_step++){

        // Start timer for CPU calculations
        cpu_start = omp_get_wtime();
    
        // Average values of array elements on the host (CPU) - excluding halo 
        #pragma omp parallel for default(shared)
        for(int i=0; i<(N+2*stencil_radius); i++)
        {
            if( (i >= stencil_radius) && (i < (stencil_radius + N)) ){
     
                double sum = 0;
                for(int j=-stencil_radius; j<(stencil_radius+1); j++){
        
                    sum = sum + A[i + j];
                }
        
                A_average_cpu[i] = sum / stencil_size; 
            }
        }
    
        // Stop timer for CPU calculations
        cpu_stop = omp_get_wtime();
        elapsed_time_cpu_compute += cpu_stop - cpu_start;
    
        // Start timer for GPU compute 
        gpuErrorCheck( hipEventRecord(gpu_start, NULL) );
    
        // Launch kernel
        average_array_elements<<<blk_in_grid, thr_per_blk>>>(d_A, d_A_average);
    
        // Stop timer for GPU compute
        gpuErrorCheck( hipEventRecord(gpu_stop, NULL) );
        gpuErrorCheck( hipEventSynchronize(gpu_stop) );
        gpuErrorCheck( hipEventElapsedTime(&elapsed_time_gpu_compute_temp, gpu_start, gpu_stop) );
        elapsed_time_gpu_compute += elapsed_time_gpu_compute_temp;
    }

    // Start timer for GPU D2H data transfer
    gpuErrorCheck( hipEventRecord(gpu_start, NULL) );

    // Copy data from device array d_A_average to host array A_average_gpu
    gpuErrorCheck( hipMemcpy(A_average_gpu, d_A_average, bytes, hipMemcpyDeviceToHost) );

    // Stop timer for GPU D2H data transfer
    gpuErrorCheck( hipEventRecord(gpu_stop, NULL) );
    gpuErrorCheck( hipEventSynchronize(gpu_stop) );
    gpuErrorCheck( hipEventElapsedTime(&elapsed_time_gpu_data_transfers_temp, gpu_start, gpu_stop) );
    elapsed_time_gpu_data_transfers +=elapsed_time_gpu_data_transfers_temp;

    // Stop timer for total time
    total_stop = omp_get_wtime();

    // Verify results - ignoring the halo at start and end of main array
    double tolerance = 1.0e-14;
    for(int i=0; i<(N+2*stencil_radius); i++)
    {
        if( (i >= stencil_radius) && (i < (stencil_radius + N)) ){

            if( fabs(A_average_cpu[i] - A_average_gpu[i]) > tolerance )
            { 
                printf("Error: value of A_average_gpu[%d] = %f instead of %f\n", i, A_average_gpu[i], A_average_cpu[i]);
                exit(1);
            }
        }
    }	

    // Free CPU memory
    free(A);
    free(A_average_cpu);
    free(A_average_gpu);

    // Free GPU memory
    gpuErrorCheck( hipFree(d_A) );
    gpuErrorCheck( hipFree(d_A_average) );

    printf("\n-----------------------------------------------\n");
    printf("__SUCCESS__\n");
    printf("-----------------------------------------------\n");
    printf("Number of Array Elements           = %d\n", N);
    printf("Number of Bytes in Array (MB)      = %zu\n", bytes / (1024*1024));
    printf("Number of Time Steps               = %d\n", total_time_steps);
    printf("Threads Per Block                  = %d\n", thr_per_blk);
    printf("Blocks In Grid                     = %d\n", blk_in_grid);
    printf("Elapsed CPU Compute Time (s)       = %f\n", elapsed_time_cpu_compute);
    printf("Elapsed GPU Compute Time (s)       = %f\n", elapsed_time_gpu_compute / 1000.0);
    printf("Elapsed GPU Data Transfer Time (s) = %f\n", elapsed_time_gpu_data_transfers / 1000.0);
    printf("Elapsed GPU Time Total (s)         = %f\n", elapsed_time_gpu_compute / 1000.0 + elapsed_time_gpu_data_transfers / 1000.0);
    printf("Elapsed Time Total (s)             = %f\n", total_stop - total_start);
    printf("-----------------------------------------------\n\n");

    return 0;
}
