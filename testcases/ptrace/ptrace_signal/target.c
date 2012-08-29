#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>


void debug_sig(int sig)
{
	if (sig == SIGSTOP) {
		printf("debug_sig: SIGSTOP\n");
		signal(SIGSTOP, SIG_DFL);
	}
	else if (sig == SIGTRAP) {
		printf("debug_sig: SIGTRAP\n");
		signal(SIGSTOP, SIG_DFL);
	}
	else
		printf("signal: %d\n", sig);
}


void target_func(int pid)
{
	struct sigaction pt_sig;
	
	pt_sig.sa_handler = debug_sig;
	sigemptyset(&pt_sig.sa_mask);
	pt_sig.sa_flags = 0;

#if 0
	if (sigaction(SIGSTOP, &pt_sig, NULL) < 0)
		printf("ERROR1: %s\n", strerror(errno));
#endif
	if (sigaction(SIGCHLD, &pt_sig, NULL) < 0)
		printf("ERROR1: %s\n", strerror(errno));
	if (sigaction(SIGTRAP, &pt_sig, NULL) < 0)
		printf("ERROR2: %s\n", strerror(errno));

	for (;;) {
		sleep(1);
		sleep(1);
		sleep(1);
	}

	exit(0);
}


int dummy_func(int pid)
{
	int status;
	int cnt = 0;

	printf("target process pid: %d\n", pid);

	for (;;) {
		/* sleep for test */
		sleep(10);
	}

	return 0;
}


int main(int argc, char *argv[])
{
	int pid;
	
	switch(pid = fork())
	{
	case 0:
		target_func(pid);
		break;
	case -1:
		fprintf(stderr, "ERROR: fork\n");
		break;
	default:
		dummy_func(pid);
		break;
	}

	return 0;
}
