/*************************************************************************
*Test Description: Singlestep test
*Print each instruction executed when child process in write() system call
*Note: MIPS don't support singlestep!
************************************************************************/

#include <sys/ptrace.h>
#include <linux/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
//#include <linux/user.h>
#include <sys/user.h>
#include <sys/syscall.h>

unsigned long register_ip, syscall_no;

int main(void)
{
#if defined(__mips__) || defined(__mips64__)
     printf("End test!! ptrace singlestep is not supported by MIPS cpu!\n");
     exit(2);
#endif

     pid_t child;
     const int long_size = sizeof(long);
     int in_singlestep = 0; 

     child = fork();
      if(child == 0) {
         if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) != 0)
	    {
	      printf("ptrace: PTRACE_TRACEME error!\n");
	      exit(1);
  	    }
         execl("./dummy2", "dummy2", NULL);
     }
      else {
         int status;
          union u {
             long val;
             char chars[long_size];
         }data;

#if defined(__i386__) || defined(__x86_64__)
	 struct user_regs_struct user_regs;
#else
	 struct pt_regs user_regs;
#endif
         int start = 0;
         long ins;
         
	 while(1) {
             wait(&status);

             if(WIFEXITED(status))
                {
                 printf("Exit with status: %d\n", status);
                 break;
                }  

             if (ptrace(PTRACE_GETREGS, child, NULL, &user_regs) != 0)
		{
		 printf("ptrace: PTRACE_GETREGS error!\n");
              	 exit(1);
		}

	     //Get the instruction pointer and syscall number
	     //Different register is used on each cpu architecture
#if defined(__i386__) || defined(__x86_64__)
		#if __WORDSIZE==64
                register_ip = user_regs.rip;
                syscall_no  = user_regs.orig_rax;
                #else
                register_ip = user_regs.eip;
                syscall_no  = user_regs.orig_eax;
                #endif
#elif defined(__arm__) 
		register_ip = user_regs.ARM_pc;
  		syscall_no  = user_regs.ARM_r7;
#elif defined(__powerpc__) 
		register_ip = user_regs.nip;
                syscall_no  = user_regs.gpr[0];	
#else
		printf("Unkown architecture.\n");
		exit(1);
#endif

              if (start == 1)
		 {
                  ins = ptrace(PTRACE_PEEKTEXT,
                               child, register_ip,
                               NULL);
                  if (ins == -1)
		     {
 		      perror("ptrace: PTRACE_PEEKTEXT error");
  		      exit(1);
		     }

                  printf("EIP: %lx Instruction "
                         "executed: %lx \n",
                          register_ip, ins);
             	 }

              if (syscall_no == SYS_write)
		 {
                  start = 1;
                  if (ptrace(PTRACE_SINGLESTEP, child, NULL, NULL) != 0)
		     {
		      printf("ptrace: PTRACE_SINGLESTEP error!\n");
                      exit(1);
		     }
                  in_singlestep = 1;
             	 }
              else
		{
                 if (ptrace(PTRACE_SYSCALL, child, NULL, NULL) != 0)
		    {
                     printf("ptrace: PTRACE_SYSCALL error!\n");
                     exit(1);
                    }
		}
         }//End while(1)
     }
     // if  in_singlestep = 0, test failed!
     if (in_singlestep  == 0)
	{
	 exit(1);
	}
	
     return 0;
}

