#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <time.h>
#include <fstream>
#include <iostream>
using namespace std;


__global__ void KMP(char* pattern, char* text, int prefixTable[], int result[], int pattern_length, int text_length) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int i = pattern_length * index;
    int j = pattern_length * (index + 2) - 1;
    
    if(i > text_length) {
        return;
    }

    if(j > text_length) {
        j = text_length;
    }

    int k = 0;        
    while (i < j) {
        if (k == -1) {
            i++;
            k = 0;
        } else if (text[i] == pattern[k]) {
            i++;
            k++;
            if (k == pattern_length) {
                result[i - pattern_length] = i - pattern_length;
                i = i - k + 1;
            }
        }
        else {
            k = prefixTable[k];
        }
    }
    return;
}

void loadInputFile(string fName, char* inputArray) {
	ifstream inputFile;

	inputFile.open(fName.c_str());
	if (inputFile.is_open()) {
		int cnt = 0;
		while (!inputFile.eof()) {
			string temp;
			getline(inputFile, temp, '\n');
			inputArray[cnt++] = atof(temp.c_str());
		}
		inputFile.close();
	}
}


void preKMP(char* pattern, int prefixTable[]) {
    int m = strlen(pattern);
    int k;
    prefixTable[0] = -1;
    for (int i = 1; i < m; i++) {
        k = prefixTable[i - 1];
        while (k >= 0) {
            if (pattern[k] == pattern[i - 1]) {
                 break;
            }
            else {
                k = prefixTable[k];
            }
        }
        prefixTable[i] = k + 1;
    }
}

int main(int argc, char* argv[]) {
    int textlen = 200000;
	int patternlen = 10;
 
    char* text = (char*)malloc(textlen * sizeof(char));
    char* pattern = (char*)malloc(patternlen * sizeof(char));
  
	std::ifstream file;
	file.open("KMP_Input_200000.txt");
	file.getline(text, textlen);
	file.close();
	file.open("pat.txt");
    file.getline(pattern, 10);
    int text_length = strlen(text);
    int pattern_length = strlen(pattern);

    char *d_text;
    char *d_pattern;

    int *prefixTable,*d_prefixTable;
    int *result,*d_result;
    prefixTable = new int[text_length];
    result = new int[text_length];
   
    for(int i = 0; i < text_length; i++) {
        result[i] = -1;
    }     

    preKMP(pattern, prefixTable);

    cudaEvent_t start, stop;
    float elapsedTime;

    cudaEventCreate( &start ); 
    cudaEventCreate( &stop );

    cudaEventRecord( start, 0 );

    cudaMalloc((void **)&d_text, text_length * sizeof(char));
    cudaMalloc((void **)&d_pattern, pattern_length * sizeof(char));
    cudaMalloc((void **)&d_prefixTable, text_length * sizeof(int));
    cudaMalloc((void **)&d_result, text_length * sizeof(int));

    cudaMemcpy(d_text, text, text_length * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_pattern, pattern, pattern_length * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_prefixTable, prefixTable, text_length * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_result, result, text_length * sizeof(int), cudaMemcpyHostToDevice);
    KMP<<<(text_length / pattern_length + 4)/4, 4>>>(d_pattern, d_text ,d_prefixTable, d_result, pattern_length, text_length);

    cudaMemcpy(result, d_result, text_length * sizeof(int), cudaMemcpyDeviceToHost);

    cudaEventRecord( stop, 0 );
    cudaEventSynchronize( stop );
    cudaEventElapsedTime( &elapsedTime, start, stop );
    cudaEventDestroy(start); 
    cudaEventDestroy(stop);

    int matches=0;
    for(int i = 0; i < text_length; i++) {
        if (result[i] != -1) {
            matches++;
        }
    }
    cout << "Length of text " << textlen << endl;
	cout << "Length of pattern " << strlen(pattern) << endl;
    cout<<"Number of matches of \""<<pattern<<"\" is "<<matches<<endl<<"Time taken: "<< elapsedTime;
    cudaFree(d_text); 
    cudaFree(d_pattern); 
    cudaFree(d_prefixTable); 
    cudaFree(d_result);
    free(text);
    free(pattern);
    return 0;
}