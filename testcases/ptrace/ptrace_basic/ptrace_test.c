/************************************************************************
*Test Description:
*1. A process can trace its child process marked as PTRACE_TRACEME.
*   The child process executs ptrace(PTRACE_TRACEME, 0, 0, 0), then stopped.
*2. The parent process runs ptrace(PTRACE_SYSCALL, pid, 0, 0), then the child 
*   process continue to run untill meet an entry or exit of a system call.
*   Then the parent process runs ptrace(PTRACE_SYSCALL, ...) again to start
*   the next loop.
*3. The parent breaks from the loop once get the SIGNAL that child process 
*   finished. Since the counter increment twice each child process system call,
*   the number of system call is harf of counter's value. 
*************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <syscall.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>

int main(void)
{
        long long counter = 0;  /*  system call counter */
        int wait_val;           /*  child's return value        */
        int pid;                /*  child's process id          */
	int ret;

        puts("Please wait...");

        switch (pid = fork()) {
        case -1:
                perror("fork");
                break;
        case 0: /*  child process starts        */
                if (ptrace(PTRACE_TRACEME, 0, 0, 0) != 0)
		   {
		    printf("ptrace: PTRACE_TRACEME error!\n");
		    exit(1);
		   }
                /* 
                 *  must be called in order to allow the
                 *  control over the child process
                 */ 
                execl("/bin/ls", "ls", NULL);
                /*
                 *  executes the program and causes
                 *  the child to stop and send a signal 
                 *  to the parent, the parent can now
                 *  switch to PTRACE_SINGLESTEP   
                 */ 
                break;
                /*  child process ends  */
        default:/*  parent process starts       */
                wait(&wait_val); 
                /*   
                 *   parent waits for child to stop at next 
                 *   instruction (execl()) 
                 */
		while (WIFSTOPPED(wait_val) && WSTOPSIG(wait_val) == SIGTRAP){
                        counter++;
                        if ((ret=ptrace(PTRACE_SYSCALL, pid, 0, 0)) != 0) {
			    printf("ptrace: PTRACE_SYSCALL error!\n");
                    	    exit(1);
			}
                        /* 
                         *   switch to system call tracing and 
                         *   release child
                         *   if unable call error.
                         */
                        wait(&wait_val);
                        /*   wait for next instruction to complete  */
                }
                /*
                 * continue to stop, wait and release until
                 * the child is finished; wait_val != 1407
                 * Low=0177L and High=05 (SIGTRAP)
                 */
        }
	printf("Number of systemcall : %lld\n", counter/2);

        return 0;
}
