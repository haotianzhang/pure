/*
* Copyright (c) 2011 Wind River Systems, Inc.
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License version 2 as
* published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
* See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*/

/*
 a simple application to test clock_gettime "CLOCK_REALTIME" flag function in different process,
*/


#include <stdio.h>   
#include <sys/types.h> 
#include <time.h>
#include <unistd.h> 
#include <stdlib.h>
#define THRESHOLD 2

int main(void)
{
	pid_t  pid;
	int fd[2]; /* provide file descriptor pointer array for pipe */ 
	time_t value1,value2; /* value for parent and child clock time */
	struct timespec tps, tpe; 
	if (pipe (fd) < 0)     /* create pipe and check for an error */
	{ 
		perror("pipe error");
		exit (1);
	}

	if ((pid = fork()) < 0)  /* apply fork and check for error */
	{ 
		perror ("error in fork");  
		exit (1);
	}
   	/* child to get clock time */ 
   	else if (pid == 0)
   	{	
		clock_gettime(CLOCK_REALTIME, &tps);
     		printf("child time %lu s \n", tps.tv_sec);
       		close (fd[0]);       /* close fd[1] leave fd[0] open */
       		write (fd[1], &tps.tv_sec, 8); /* write the clock value, which uses 8 bytes */
   	}
	/* parent to getclock time */
	else
	{
		sleep(1);
		clock_gettime(CLOCK_REALTIME, &tpe);
		value2=tpe.tv_sec;
		close (fd[1]);       /* close fd[1] leave fd[0] open */
		read (fd[0], &value1, 8);  /* read integer as 8 bytes */
		printf("parent time %lu s \n", value2);
                printf("diff is %lu s\n",value2-value1);
                if ((value2-value1)<=THRESHOLD)
                {
                        printf("clock gettime PASS\n");
                }
                else
                {
                        printf("clock gettime FAIL\n");
			exit(1);
                }
	}
	return 0;
}
