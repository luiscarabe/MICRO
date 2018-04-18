#include <stdio.h>
#include <stdlib.h>
#define TRUE 1
#define FALSE 0
#define NUMBERATTEMPTS 5
unsigned int checkSecretNumber(unsigned char* number);
void fillUpAttempt(unsigned int attempt, unsigned char* attemptDigits);
unsigned int computeMatches(unsigned char* secretNum, unsigned char* attemptDigits);
unsigned int computeSemiMatches(unsigned char* secretNum, unsigned char* attemptDigits);
//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////
int main( void )
{
	int t;
	unsigned char secretNum[4];
	unsigned char attemptDigits[4];
	unsigned int numAttempts, attempt, matches, semimatches, repeated, i;
	srand((unsigned) time(&t));
	do {
		for (i=0; i<4; i++)
			secretNum[i] = rand() % 10;
		repeated = checkSecretNumber(secretNum);
	} while (repeated == TRUE);
	numAttempts = 0;
	//printf("Secret num: %u%u%u%u\n", secretNum[0], secretNum[1], secretNum[2], secretNum[3]);
	do {
		numAttempts++;
		do
		{
			printf("Please enter attempt %u [0000 - 9999]: ", numAttempts );
			scanf("%u", &attempt);
		}
		while ( attempt > 9999);
		fillUpAttempt( attempt, attemptDigits );
		matches = computeMatches(secretNum, attemptDigits);
		semimatches = computeSemiMatches(secretNum, attemptDigits);
		printf("Number of matches: %u\t", matches);
		printf("Number of semi-matches: %u\n", semimatches );
	} while ((matches != 4) && (numAttempts != NUMBERATTEMPTS));
	if (matches == 4)
		printf("Secret number guessed: YOU WIN!!!\n");
	else
		printf("Number of attempts exceeded: YOU LOSE :(\n");
		
	printf("Secret number: %u%u%u%u\n", secretNum[0], secretNum[1], secretNum[2], secretNum[3]);
	return 0;
}