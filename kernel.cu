#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <cuda.h>
#include <math.h>
#include "dotprod.h"

__global__ void kernel(unsigned int rows, unsigned int cols ,unsigned char *mdata,unsigned char *vdata,float *results){
    /*     unsigned char y;*/
	
        int tid  = threadIdx.x + blockIdx.x * blockDim.x;
    /*int j;*/
	
    /*Coalescent Memory Access*/
		
    /*for(j=0;j<(rows*cols);j++)*/
    if(tid<(rows*cols))
    {
        /*printf("\nThread: %d , mdata:%f",tid,((float)mdata[tid]-48));
        printf("\nThread: %d , vdata:%f",tid,((float)vdata[(tid+1)%cols]-48));
        printf("\nceil: %d.",(tid/cols));*/
        /*printf("\nIndex is : %d. Result is : %d.",(tid%cols),results[(tid/cols)]);*/
        /*printf("\nsize of result %d", sizeof(results[0]));*/
        printf("\nTaking Product of %f and %f:",(float)(mdata[tid]-48),(float)(vdata[(tid%cols)])-48);
        results[(tid/cols)]+=(((float)(mdata[tid]-48))*((float)(vdata[(tid%cols)])-48)));
    }
}

