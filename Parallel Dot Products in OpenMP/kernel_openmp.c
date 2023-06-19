#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "kernel_openmp.h"

void kernel(float *matrix, float *vector, float *result, int rows, int cols, int jobs){ 
    /*
    int tid = blockIdx.x * blockDim.x + threadIdx.x; 
    */
  
    int i, j;
    int stop;
    int tid = omp_get_thread_num();
    if ((tid+1)*jobs > rows){
        stop = rows;
    }
    else{
        stop = (tid+1) * jobs;
    }
    printf("thread_id = %d\nstart = %d\nstop = %d\n", tid, tid * jobs, stop);
    float sum = 0;
    for (j = tid * jobs; j < stop; j++){
        if( j < rows){

            // Code for testing, comments preserved intentionally.
            
            /*printf("\nThread: %d , mdata:%f",tid,((float)mdata[tid]-48));
            printf("\nThread: %d , vdata:%f",tid,((float)vdata[(tid+1)%cols]-48));
            printf("\nceil: %d.",(tid/cols));*/
            /*printf("\nIndex is : %d. Result is : %d.",(tid%cols),results[(tid/cols)]);*/
            /*printf("\nsize of result %d", sizeof(results[0]));*/
   
            for(i = 0; i < cols; i++){
                sum += matrix[j * cols + i] * vector[i];
            }
            result[j] = sum;
        }
    }
} 