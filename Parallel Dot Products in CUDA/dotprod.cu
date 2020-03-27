#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>
#include <time.h>
#include <sys/time.h>
#include <math.h>
#include "dotprod.h"



int main(int argc ,char* argv[]) 
{

	FILE *fp1;
	FILE *fp2;
	size_t size;
	  
	/* Initialize rows, cols, ncases, ncontrols from the user */
	unsigned int rows=atoi(argv[1]);
    unsigned int cols=atoi(argv[2]);
	int CUDA_DEVICE = atoi(argv[5]);
	int THREADS = atoi(argv[6]);
	printf("rows=%d cols=%d CUDA_DEVICE=%d Threads=%d\n",rows,cols,CUDA_DEVICE,THREADS);

	cudaError err = cudaSetDevice(CUDA_DEVICE);
	if(err != cudaSuccess) { printf("Error setting CUDA DEVICE\n"); exit(EXIT_FAILURE); }

	/*Host variable declaration */

	//int THREADS = 32;
	int BLOCKS;
	float* host_results = (float*) malloc(cols * sizeof(float)); 
	struct timeval starttime, endtime;
	clock_t start, end;
	float seconds;
	unsigned int jobs; 
	unsigned long i;


	/*Kernel variable declaration */
	unsigned char *dev_dataM ;
	unsigned char *dev_dataV ;
	float *results;
        char *line = NULL; size_t len = 0;
	char *token, *saveptr;

	start = clock();

	/* Validation to check if the Matrix data file is readable */
	fp1 = fopen(argv[3], "r");
	if (fp1 == NULL) {
    		printf("Cannot Open the File: %s", argv[3]);
		return 0;
    }
    
    /* Validation to check if the Vector data file is readable */
	fp2 = fopen(argv[4], "r");
	if (fp2 == NULL) {
    		printf("Cannot Open the File: %s", argv[4]);
		return 0;
	}

	size = (size_t)((size_t)rows * (size_t)cols);
	printf("Size of the data = %lu\n",size);

	fflush(stdout);

    /*Allocate memory for Matrix*/
    unsigned char *dataM = (unsigned char*)malloc((size_t)size); 

	if(dataM == NULL) {
	        printf("ERROR: Memory for Matrix data not allocated.\n");
    }
    
    /*Allocate memory for Vector*/  /*$$CHECK$$ whether shoukld be row or column*/
    unsigned char *dataV = (unsigned char*)malloc((size_t)cols);

    if(dataV == NULL) {
        printf("ERROR: Memory for Vector data not allocated.\n");
	}

	gettimeofday(&starttime, NULL);

	/* Transfer the Matrix Data from the file to CPU Memory */
	i=0;
	while (getline(&line, &len, fp1) != -1) {
                token = strtok_r(line, " ", &saveptr);
                while(token != NULL){
						dataM[i] = *token;
						printf("\n %d", (int) *token);
                        i++;
                        token = strtok_r(NULL, " ", &saveptr);
                }
		 /* Transfer the Vector Data from the file to CPU Memory */
		}
	
         i=0;
         while (getline(&line, &len, fp2) != -1) {
                     token = strtok_r(line, " ", &saveptr);
                     while(token != NULL){
							 dataV[i] = *token;
							/* printf( *token);*/
							 printf("\n %d", (int) dataV[i] );
                             i++;
                             token = strtok_r(NULL, " ", &saveptr);
                     }
/*
                cur=0; read=-1;
                token = strtok(line, " ");
                while(sscanf(line+cur, "%d%n", &tmp, &read)==1){
                        dataT[i] = (char)(((int)'0')+tmp);
                        cur += read;
                        i++;
                }
*/
  	}
    fclose(fp1);
    fclose(fp2);
        printf("\nData read done.\n");
        fflush(stdout);

        gettimeofday(&endtime, NULL);
        seconds+=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);

        printf("time to read data = %f\n", seconds);

	/* allocate the Memory in the GPU for Matrix data */	   
        gettimeofday(&starttime, NULL);
	err = cudaMalloc((unsigned char**) &dev_dataM, (size_t) size * (size_t) sizeof(unsigned char) );
	if(err != cudaSuccess) { printf("Error mallocing Matrix data on GPU device\n"); }
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
	printf("time for Matrix cudamalloc=%f\n", seconds);


    
    /* allocate the Memory in the GPU for Vector data */	   
        gettimeofday(&starttime, NULL);
	err = cudaMalloc((unsigned char**) &dev_dataV, (size_t) cols * (size_t) sizeof(unsigned char) );
	if(err != cudaSuccess) { printf("Error mallocing Vector data on GPU device\n"); }
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
    printf("time for Vector cudamalloc=%f\n", seconds);
    
    /* allocate the Memory in the GPU for Results Vector data */	
        gettimeofday(&starttime, NULL);
	err = cudaMalloc((float**) &results, rows * sizeof(float) );
	if(err != cudaSuccess) { printf("Error mallocing Vector results on GPU device\n"); }
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
	printf("time for Results cudamalloc=%f\n", seconds);

	/*Copy the Matrix data to GPU */
        gettimeofday(&starttime, NULL);
	err = cudaMemcpy(dev_dataM, dataM, (size_t)size * (size_t)sizeof(unsigned char), cudaMemcpyHostToDevice);
	if(err != cudaSuccess) { printf("Error copying Matrix data to GPU\n"); }
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
    printf("time to copy Matrix Data to GPU=%f\n", seconds);
    
    /*Copy the Vector data to GPU */
        gettimeofday(&starttime, NULL);
	err = cudaMemcpy(dev_dataV, dataV, (size_t)cols * (size_t)sizeof(unsigned char), cudaMemcpyHostToDevice);
	if(err != cudaSuccess) { printf("Error copying Vector data to GPU\n"); }
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
	printf("time to copy Vector Data to GPU=%f\n", seconds);

	jobs = cols;
	BLOCKS = ceil((jobs + THREADS - 1)/THREADS);
	printf("Number of Blocks:%d\n", BLOCKS);
        gettimeofday(&starttime, NULL);

	/*Calling the kernel function */
	kernel<<<BLOCKS,THREADS>>>(rows,cols,dev_dataM,dev_dataV,results);
        gettimeofday(&endtime, NULL); seconds=((double)endtime.tv_sec+(double)endtime.tv_usec/1000000)-((double)starttime.tv_sec+(double)starttime.tv_usec/1000000);
	printf("time for kernel=%f\n", seconds);
		
	/*Copy the results back in host*/
	cudaMemcpy(host_results,results,rows * sizeof(float),cudaMemcpyDeviceToHost);
	printf("\nResults:\n");
	for(int k = 0; k < jobs; k++) {
		printf("\n %f ", host_results[k]);
	}
	printf("\n");

    cudaFree( dev_dataM );
    cudaFree( dev_dataV );
	cudaFree( results );

	end = clock();
	seconds = (float)(end - start) / CLOCKS_PER_SEC;
	printf("Total time = %f\n", seconds);

	return 0;

}
