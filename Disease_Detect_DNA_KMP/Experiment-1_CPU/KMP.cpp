#include<time.h>
#include<chrono>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int matches = 0;

void calculatePrefixArray(char* pat, int M, int* prefixArray)
{
	// longest prefix length
	int len = 0;
	// First element value of prefix Array is always zero
	prefixArray[0] = 0;
	//Calculate values of prefixArray[1...M-1]
	int i = 1;
	while (i < M)
	{
		if (pat[i] == pat[len])
		{
			len++;
			prefixArray[i] = len;
			i++;
		}
		else
		{
			if (len != 0)
			{
				len = prefixArray[len - 1];

			}
			else {
				prefixArray[i] = 0;
				i++;
			}
		}
	}
}

void KMP(char* pat, char* txt)
{

	int M = strlen(pat);
	int N = strlen(txt);

	// create prefixArray[] that will hold the longest prefix suffix
	int* prefixArray = (int*)malloc(M * sizeof(int));

	// Preprocess the pattern (calculate prefixArray[] array)
	calculatePrefixArray(pat, M, prefixArray);

	int i = 0;  // index for txt[]
	int j = 0;  // index for pat[]
	while (i < N)
	{
		if (pat[j] == txt[i])
		{
			j++;
			i++;
		}

		if (j == M)
		{
			//Found pattern at index i-j
			matches++;

			j = prefixArray[j - 1];
		}

		// mismatch after j matches
		else if (i < N && pat[j] != txt[i])
		{
			// SKip prefixArray[0..prefixArray[j-1]] characters as they will match
			if (j != 0)
				j = prefixArray[j - 1];
			else
				i = i + 1;
		}
	}
}

int main()
{
	int textlen = 100000;
	int patternlen = 11;
	char* txt = (char*)malloc(textlen* sizeof(char));
	char* pat = (char*)malloc(patternlen * sizeof(char));
	
	std::ifstream file;
	file.open("KMP_Input_100000.txt");
	file.getline(txt, textlen);
	file.close();
	time_t begin, end;
	file.open("pattern_10.txt");
	while (file.getline(pat, patternlen))
	{
		auto start = std::chrono::high_resolution_clock::now();
		KMP(pat, txt);
		auto finish = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = finish - start;
		cout << "Length of text " << textlen << endl;
		cout << "Length of pattern " << strlen(pat) << endl;
		cout << "Number of matches of \"" << pat << "\" is " << matches << endl ;
		cout << "Elapsed time: " << elapsed.count() *1000 << " ms\n";
		matches = 0;
	}
	file.close();


	return 0;
}