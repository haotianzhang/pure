
#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <pthread.h>
#include <string.h>

static int shmid;

pthread_mutex_t * get_shmem_mutex_ptr(void)
{
  	key_t key = 0x11d7;
	void *shm;
  
  	shmid = shmget(key, sizeof(pthread_mutex_t), IPC_CREAT | IPC_EXCL | 0x1b6);
  
  	if (shmid < 0) {
		printf("failed to create shm, err=%s\n", strerror(errno));
		printf("trying to find it ...\n");
		shmid = shmget(key, sizeof(pthread_mutex_t), 0x1b6);
		if (shmid < 0) {
			printf("failed to find shmem, err=%s\n", strerror(errno));
			exit(-1);
		}
		shm = shmat(shmid, NULL, 0);
	} else {
		shm = shmat(shmid, NULL, 0);
	}
	
	return (pthread_mutex_t *)shm;
}

pthread_mutex_t * shmem_mutex_init(void)
{
	pthread_mutex_t * pmutex = get_shmem_mutex_ptr();

	pthread_mutexattr_t attr;
	
	pthread_mutexattr_init (&attr);
	pthread_mutexattr_setpshared (&attr, PTHREAD_PROCESS_SHARED);
	pthread_mutexattr_setprotocol (&attr, PTHREAD_PRIO_INHERIT);
	pthread_mutexattr_setrobust_np (&attr, PTHREAD_MUTEX_STALLED_NP);
	pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_ERRORCHECK);
	if (pthread_mutex_init (pmutex, &attr) != 0) {
    		printf("Init mutex failed, err=%s\n", strerror(errno));
		pthread_mutexattr_destroy (&attr);
		return NULL;
	}

	return pmutex;
}

void long_running_task(void)
{
        int i, j;

        /* do nothing, just for hogging the CPU */
        for (i = 0; i < 1000000; i++)
                for (j = 0; j < 1000000; j++)
                        j = j;
}

int main(void)
{
	int ret;
	int i, flag;
	pthread_mutex_t *global_mutex;

	if ((global_mutex = shmem_mutex_init()) == NULL)
		exit(-2);
	
	while (1) {
		pthread_mutex_lock(global_mutex);
		long_running_task();
		pthread_mutex_unlock(global_mutex);
	}

	return 0;
}

		

	 
	

