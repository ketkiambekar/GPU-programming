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
	
	int jobs;	
	jobs = ((rows + nprocs - 1) / nprocs);	
	printf("jobs = %d\n", jobs);

#pragma omp parallel num_threads(nprocs)
	
	kernel(dataM, dataV, result, rows, cols, jobs);
	
	
	/*Print out the result*/
	int k;
	printf("Results :\n");
    for(k = 0; k < rows; k++) {
		printf("\n%f ", result[k]);
	}
	printf("\n");
  
	
	return 0;
}