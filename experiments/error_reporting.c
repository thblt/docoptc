#include <stdio.h>
#include <stdlib.h>

typedef struct {
	int logLevel;
	const char * inputFile;
	const char * outputFile;
} cmdLineArgs;

void docoptc_fail(cmdLineArgs *args, void *errPoint, const char *msg) {
	if (errPoint == &args->logLevel) {
		printf("-v | -q");
	} else if (errPoint == &args->inputFile) {
		printf("-i %s", args->inputFile);
	}
	else if (errPoint == &args->outputFile) {
		printf("-o");
	}
printf("\n%s\n", msg);
exit(-1);
}

int main(int argc, char * argv[])
{
	cmdLineArgs x = {0, "myprogram.docopt", "output"};
	docoptc_fail(&x,&x.inputFile,"Can't open input file.");

}
