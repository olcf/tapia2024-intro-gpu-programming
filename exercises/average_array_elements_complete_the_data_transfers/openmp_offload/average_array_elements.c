#include <stdio.h>
#include <omp.h>
#include <math.h>
#include <stdlib.h>

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

    // Fill host array A with random numbers on host
    for(int i=0; i<(N+2*stencil_radius); i++)
    {
        A[i] = (double)rand()/(double)RAND_MAX;
    }

    double total_start, total_stop;
    double cpu_start, cpu_stop, gpu_start, gpu_stop;
    double elapsed_time_cpu_compute        = 0.0;
    float  elapsed_time_gpu_compute_temp;
    float  elapsed_time_gpu_compute        = 0.0;
    float  elapsed_time_gpu_data_transfers_temp;
    float  elapsed_time_gpu_data_transfers = 0.0;

    // Start timer for total time
    total_start = omp_get_wtime();

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
           
             // If id is not in the halo...
       //TODO: write code to move data from host to device for target region
       gpu_start = omp_get_wtime();
      
      #pragma omp parallel for
       for(int i=0; i<(N+2*stencil_radius); i++){
         if( (i >= stencil_radius) && (i < (stencil_radius + N)) ) {
        // Calculate sum of stencil elements
            double sum = 0.0;

            for(int j=-stencil_radius; j<=stencil_radius; j++){
            sum = sum + A[i + j];
        }

        // Use sum to find average and store it in a_average.
        A_average_gpu[i] = sum / stencil_size;
           }
	}
      #pragma omp target exit data map(delete:A[:N]) 
        gpu_stop = omp_get_wtime();
	elapsed_time_gpu_compute += gpu_stop - gpu_start;

    }
   
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
  
    printf("\n-----------------------------------------------\n");
    printf("__SUCCESS__\n");
    printf("-----------------------------------------------\n");
    printf("Number of Array Elements           = %d\n", N);
    printf("Number of Bytes in Array (MB)      = %zu\n", bytes / (1024*1024));
    printf("Number of Time Steps               = %d\n", total_time_steps);
    printf("Elapsed CPU Compute Time (s)       = %f\n", elapsed_time_cpu_compute);
//    printf("Elapsed GPU Compute Time (s)       = %f\n", elapsed_time_gpu_compute);
    printf("Elapsed GPU Time Total (s)         = %f\n", elapsed_time_gpu_compute + elapsed_time_gpu_data_transfers);
    printf("Elapsed Time Total (s)             = %f\n", total_stop - total_start);
    printf("-----------------------------------------------\n\n");

    return 0;
}
