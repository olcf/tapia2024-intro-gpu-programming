//#include "../../common/hip_translator.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Size of array
#define N 1048576

// Kernel
/*__global__ void vector_addition(double *a, double *b, double *c)
{
    int id = blockDim.x * blockIdx.x + threadIdx.x;
    if(id < N) c[id] = a[id] + b[id];
}*/

// Main program
int main()
{
    // Number of bytes to allocate for N doubles
    size_t bytes = N*sizeof(double);

    // Allocate memory for arrays A, B, and C on host
    double *A = (double*)malloc(bytes);
    double *A_squared = (double*)malloc(bytes);
       

    // Initializing the Arrays A and A_squared
    for(int i=0; i<N; i++)
    {
        A[i] = (double)i;
        A_squared[i] = 0.0;
    }

    //Summing arrays A and B for C
    #pragma omp target map(to:A[:N]) map(from:  A_squared[:N])
    #pragma omp parallel for
    for(int i=0; i<N; i++)
    {
	    A_squared[i] = A[i] * A[i];
    }

    // Copy data from host arrays A and B to device arrays d_A and d_B
   // cudaMemcpy(d_A, A, bytes, cudaMemcpyHostToDevice);
    //cudaMemcpy(d_B, B, bytes, cudaMemcpyHostToDevice);

    // Set execution configuration parameters
    //      thr_per_blk: number of HIP threads per grid block
    //      blk_in_grid: number of blocks in grid
    // int thr_per_blk = 128;
    // int blk_in_grid = ceil( float(N) / thr_per_blk );

    // Launch kernel
   // vector_addition<<<blk_in_grid, thr_per_blk>>>(d_A, d_B, d_C);

    // Copy data from device array d_C to host array C
   // cudaMemcpy(C, d_C, bytes, cudaMemcpyDeviceToHost);

    // Verify results
    double tolerance = 1.0e-14;
    for(int i=0; i<N; i++)
    {
        if( fabs((A_squared[i] - A[i] * A[i])) > tolerance )
        { 
            printf("Error: value of A_squared[%d] = %f instead of 2.0\n", i, A_squared[i]);
            exit(-1);
        }
    }	

    // Free CPU memory
    free(A);
    free(A_squared);
//    free(C);

    // Free GPU memory
   /* cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);*/

    printf("\n---------------------------\n");
    printf("__SUCCESS__\n");
    printf("---------------------------\n");
    printf("N                 = %d\n", N);
//    printf("Threads Per Block = %d\n", thr_per_blk);
//    printf("Blocks In Grid    = %d\n", blk_in_grid);
    printf("---------------------------\n\n");

    return 0;
}
