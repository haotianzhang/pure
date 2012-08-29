#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/ptrace.h>
#include <sys/wait.h>

int ptrace_control(int pid, int loops)
{
	int status;
	int n;
	
	for (n = 0; n < loops; n++) {
		printf("\n");

		/* Step 1  */
		printf("ptrace: step1: PTRACE_ATTACH\n");
	    if (ptrace(PTRACE_ATTACH, pid, NULL, NULL) < 0)
			printf("ERROR: %s\n", strerror(errno));
			
	    /* Step 2  */
		printf("ptrace: step2: waitpid\n");
		if (waitpid(pid, &status, 0) < 0)
			printf("ERROR: %s\n", strerror(errno));
		if (WIFSTOPPED(status))
			printf("signal %d\n", WSTOPSIG(status));
		
		sleep(1);

		/* Step 3  */
		printf("ptrace: step3: PTRACE_SYSCALL\n");
		if (ptrace(PTRACE_SYSCALL, pid, NULL, NULL) < 0)
			printf("ERROR: %s\n", strerror(errno));

	    /* Step 4  */
		printf("ptrace: step4: waitpid\n");
		if (waitpid(pid, &status, 0) < 0)
			printf("ERROR: %s\n", strerror(errno));
		if (WIFSTOPPED(status))
			printf("signal %d\n", WSTOPSIG(status));

		sleep(1);

		/* Step 5  */
		printf("ptrace: step5: PTRACE_DETACH\n");
		if (ptrace(PTRACE_DETACH, pid, NULL, NULL) < 0)
			printf("ERROR: %s\n", strerror(errno));

		/* sleep for test */
		sleep(5);
	}

	return 0;
}


int main(int argc, char *argv[])
{
	int child_pid;
	int loops;

    if (argc < 3){
         fprintf(stderr, "%s <pid> <loops>\n", argv[0]);
         return 1;
    }
	printf("debug ptrace start!\n");

	child_pid = atoi(argv[1]);
	loops = atoi(argv[2]);
	printf("debug ptrace child_pid: %d\n", child_pid);
	printf("debug ptrace loops: %d\n", loops);

	ptrace_control(child_pid, loops);

	return 0;
}
