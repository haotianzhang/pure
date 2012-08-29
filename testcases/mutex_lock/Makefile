PREFIX = /opt/pure/testcases
TARGET=mutex_lock1 mutex_lock2
CFGS_FILES = $(wildcard *.cfg)
INC_FILES = $(wildcard *.inc)

DIR_PATH_LEN:=`dirname $(shell pwd) | wc -c`
START_IDX=$(shell expr $(DIR_PATH_LEN) + 1)
TESTNAME=`echo $(shell pwd) | cut -c $(START_IDX)-`

all: mutex_lock1 mutex_lock2

mutex_lock1: mutex_lock1.c
	$(CC) mutex_lock1.c -o mutex_lock1  -pthread -D_GNU_SOURCE
mutex_lock2: mutex_lock2.c
	$(CC) mutex_lock2.c -o mutex_lock2 -pthread -D_GNU_SOURCE

clean:
	rm -f mutex_lock1 mutex_lock2
install:
	chmod +x mutex_lock1 mutex_lock2
	mkdir -p ${DESTDIR}/${PREFIX}/${TESTNAME}
	cp $(CFGS_FILES) $(INC_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot ${TARGET}  ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot runtest.sh README  ${DESTDIR}/${PREFIX}/${TESTNAME}
