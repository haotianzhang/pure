#include <sys/ptrace.h>
#include <linux/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
//#include <linux/user.h>
#include <sys/user.h>

unsigned long register_ip;

const int long_size = sizeof(long);

void getdata(pid_t child, long addr,
             char *str, int len)
{
    char *laddr;
    int i, j, k;
    union u {
            long int val;
            char chars[long_size];
    }data;

    i = 0;
    j = len / long_size;
    laddr = str;
    while(i < j) {
        data.val = ptrace(PTRACE_PEEKDATA, child,
                          addr + i * long_size, NULL);
        memcpy(laddr, data.chars, long_size);
	//debug
        printf("<I>EIP: %lx\n", addr + i * long_size);
        for(k=0; k<long_size; k++)
          printf("data.chars[%d]:%x\n",k, (unsigned char)data.chars[k]);

        ++i;
        laddr += long_size;
    }
    j = len % long_size;
    if(j != 0) {
        data.val = ptrace(PTRACE_PEEKDATA, child,
                          addr + i * long_size, NULL);
        memcpy(laddr, data.chars, j);
	//debug
        printf("<II>EIP: %lx\n", addr + i * long_size);
        for(k=0; k<j; k++)
          printf("data.chars[%d]:%x\n",k, (unsigned char)data.chars[k]);
    }
    str[len] = '\0';
}

void putdata(pid_t child, long addr,
             char *str, int len)
{
    char *laddr;
    int i, j;
    union u {
            long int val;
            char chars[long_size];
    }data;

    i = 0;
    j = len / long_size;
    laddr = str;
    while(i < j) {
        memcpy(data.chars, laddr, long_size);
        ptrace(PTRACE_POKEDATA, child,
               addr + i * long_size, data.val);
        ++i;
        laddr += long_size;
    }
    j = len % long_size;
    if(j != 0) {
        memcpy(data.chars, laddr, j);
        ptrace(PTRACE_POKEDATA, child,
               addr + i * long_size, data.val);
    }
}

int main(int argc, char *argv[])
{
    pid_t traced_process;
#if defined(__i386__) || defined(__x86_64__)
    struct user_regs_struct user_regs;
#else
    struct pt_regs user_regs;
#endif

    long ins;
    int ins_len, k;

    //Instructions to generate soft interrupt 
#if defined(__i386__)
    /* int 0x80, int3 */
    ins_len = 4;
    char code[] = {0xcd,0x80,0xcc,0x00};
#elif defined(__x86_64__)
    ins_len = 8;
    char code[] = {0xcd,0x80,0xcc,0x00,0x00,0x00,0x00,0x00};
#elif defined(__arm__)
    /* undefined instruction interrupt */
    /* code: 0xef9f00001*/ 
    ins_len = 4;
    char code[] = {0x01,0x00,0x9f,0xef};
#elif defined(__mips__) || defined(__mips64__)
    ins_len = 12;
    //nop, break, nop
    char code[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0d,0x00,0x00,0x00,0x00};
#elif defined(__powerpc__) 
    /* invalid instruction */
    ins_len = 4;
    char code[] = {0x00,0x00,0x00,0x00};
#else
    printf("Unkown architecture.\n");
    exit(1);
#endif
  
    char backup[ins_len + 1];
    char check[ins_len + 1];
    
    if(argc != 2) {
        printf("Usage: %s <pid to be traced> ",
               argv[0], argv[1]);
        exit(1);
    }
    traced_process = atoi(argv[1]);
    if (ptrace(PTRACE_ATTACH, traced_process, NULL, NULL) != 0)
	{
	 printf("ptrace: PTRACE_ATTACH error!\n");
         exit(1); 
	}

    int wait_val;
    wait(&wait_val);

    if ( !WIFSTOPPED(wait_val) )
        {
	 printf("<1> Ptrace test failed! wait_val:%d\n", wait_val);
         exit(1);
        }

    if (ptrace(PTRACE_GETREGS, traced_process, NULL, &user_regs) != 0)
	{
	 printf("ptrace: PTRACE_GETREGS error!\n");
         exit(1);
	}

    //Get the instruction pointer and syscall number
#if defined(__i386__)
    register_ip = user_regs.eip;
#elif defined(__x86_64__)
    register_ip = user_regs.rip;
#elif defined(__arm__) 
    register_ip = user_regs.ARM_pc;
#elif defined(__mips__) || defined(__mips64__)
    register_ip = user_regs.cp0_epc;
#elif defined(__powerpc__) 
    register_ip = user_regs.nip;
#else
    printf("Unkown architecture.\n");
    exit(1);
#endif

    //debug
    printf("The current value of register_ip: %lx\n", register_ip);

    /**//* Copy instructions into a backup variable */
    getdata(traced_process, register_ip, backup, ins_len);
    /**//* Put the breakpoint */
    puts("\n//Put the breakpoint codes\n");
    for(k=0; k<ins_len; k++)
    {
     printf("code[%d]:%x\n",k, (unsigned char)code[k]);
    }
    putdata(traced_process, register_ip, code, ins_len);
    //check it
    puts("\n//CHECK codes for break//\n");
    getdata(traced_process, register_ip, check, ins_len);
    /**//* Let the process continue and execute
       the break instruction */

    if (ptrace(PTRACE_CONT, traced_process, NULL, NULL) != 0)
	{
	 printf("ptrace: PTRACE_CONT error!\n");
         exit(1);
	}

    wait(&wait_val);

    if ( !WIFSTOPPED(wait_val) )
        {
	 printf("<2> Ptrace test failed! wait_val:%d\n", wait_val);
         exit(1);
        }

    printf("*******The process stopped, putting back********\n "
           "*******   the original instructions!    ********\n");
    printf("*******Press <enter> to continue:       \n ");
    getchar();

    putdata(traced_process, register_ip, backup, ins_len);

    /**//* Setting the rip back to the original
       instruction to let the process continue */
    if (ptrace(PTRACE_SETREGS, traced_process, NULL, &user_regs) != 0)
	{
         printf("ptrace: PTRACE_SETREGS error!\n");
         exit(1);
        }

    if (ptrace(PTRACE_DETACH, traced_process, NULL, NULL) != 0)
	{
         printf("ptrace: PTRACE_DETACH error!\n");
         exit(1);
        }
 
    return 0;
}
