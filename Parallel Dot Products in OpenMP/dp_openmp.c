/*Arguments:
//1.Rows
//2.Columns
//3.Matrix File
//4.Vector File
//5.No.of Threads
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "kernel_openmp.h"

int main(int argc, char const *argv[]){
	/*Set up CUDA device*/
	/*
	int CUDA_DEVICE = atoi(argv[5]);
	cudaError err = cudaSetDevice(CUDA_DEVICE);
	if(err != cudaSuccess){
		printf("Error setting cuda device\n");
		exit(EXIT_FAILURE);
	}
	*/
	/*Host variable declaration */
	FILE *fp1;
	FILE *fp2;

	/* Initialize rows, cols from the user */
	int rows = atoi(argv[1]);
	int cols = atoi(argv[2]);
	int nprocs = atoi(argv[5]);

	/*Kernel variable declaration and memory allocation */
	float* dataM = (float*) malloc(rows * cols * sizeof(float));
	float* dataV = (float*) malloc(cols * sizeof(float));
	float* result = (float*) malloc(rows * sizeof(float));
	/*
	cudaMallocHost((void **) &dataM, sizeof(float) * rows * cols);
	cudaMallocHost((void **) &dataV, sizeof(float) * cols);
	cudaMallocHost((void **) &result, sizeof(float) * rows);
	*/
	/*Read file*/
	/* Validation to check if the Matrix data file is readable */
	fp1 = fopen(argv[3], "r");
	if (fp1 == NULL) {
		printf("Cannot Open the File: %s", argv[3]);
	return 0;
	}
	long m = 0;
	char *line1 = NULL;
	size_t len1 = 0;
	char *token1, *saveptr1;
	while (getline(&line1, &len1, fp1) != -1){
		token1 = strtok_r(line1, " ", &saveptr1);
		while (token1 != NULL){
			dataM[m] = atof(token1);
			m = m + 1;
			token1 = strtok_r(NULL, " ", &saveptr1);
		}
	}

	fclose(fp1);
	printf("Reading Data-Matrix done\n");
	fflush(stdout);

	/* Validation to check if the Vector data file is readable */
	fp2 = fopen(argv[4], "r");
	if (fp2 == NULL) {
		printf("Cannot Open the File: %s", argv[4]);
	return 0;
	}
	char *line2 = NULL;
	size_t len2 = 0;
	char *token2, *saveptr2;
	long v = 0;
	while (getline(&line2, &len2, fp2) != -1){
		token2 = strtok_r(line2, " ", &saveptr2);
		while (token2 != NULL){
			dataV[v] = atof(token2);
			v = v + 1;
			token2 = strtok_r(NULL, " ", &saveptr2);
		}
	}
	fclose(fp2);
	printf("Reading Data-Vector done\n");
	fflush(stdout);

    /*Allocate memory space on the GPU*/ 
	/*
    float *data_mat, *data_vec, *data_res;
	err = cudaMalloc((void **) &data_mat, sizeof(float) * rows * cols);
	if(err != cudaSuccess){
		printf("Error in allocating memory for matrix on the GPU\n");
	}
    err = cudaMalloc((void **) &data_vec, sizeof(float) * cols);
	if(err != cudaSuccess){
		printf("Error in allocating memory for Vector on the GPU\n");
	}
	err = cudaMalloc((void **) &data_res, sizeof(float) * rows);
	if(err != cudaSuccess){
		printf("Error in allocating memory for Result on the GPU\n");
	}
	*/
    /*// copy matrix A and B from host to device memory*/
	/*
    err = cudaMemcpy(data_mat, dataM, sizeof(float) * rows * cols, cudaMemcpyHostToDevice);
	if(err != cudaSuccess){
		printf("Error copying matrix to GPU\n");
	}
	err = cudaMemcpy(data_vec, dataV, sizeof(float) * cols, cudaMemcpyHostToDevice);
	if(err != cudaSuccess){
		printf("Error copying vector to GPU\n");
	}
	*/
	/*int THREADS = 32;*/
	int jobs;
	/*int BLOCKS;*/
	/*jobs = rows;*/
	jobs = ((rows + nprocs - 1) / nprocs);
	/*BLOCKS = (jobs + THREADS - 1)/THREADS;*/
	printf("jobs = %d\n", jobs);
#pragma omp parallel num_threads(nprocs)
	/*kernel<<<BLOCKS, THREADS>>>(data_mat, data_vec, data_res, rows, cols);*/
	kernel(dataM, dataV, result, rows, cols, jobs);
	/*copy results from GPU to host*/
	/*
	err = cudaMemcpy(result, data_mat, sizeof(float) * rows, cudaMemcpyDeviceToHost);
	if(err != cudaSuccess){
		printf("Error copying results from GPU\n");
	}
    cudaThreadSynchronize();
	*/
	
	/*Print out the result*/
	int k;
	printf("Results :\n");
    for(k = 0; k < rows; k++) {
		printf("\n%f ", result[k]);
	}
	printf("\n");
    // free memory
	/*
    cudaFree(data_mat);
    cudaFree(data_vec);
    cudaFree(data_res);
    cudaFreeHost(dataM);
    cudaFreeHost(dataV);
    cudaFreeHost(result);
    */
	return 0;
}