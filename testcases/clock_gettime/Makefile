
PREFIX = /opt/pure/testcases
TARGET=clock_gettime
FLAGS= -Wall -Wno-nonnull -lrt -O2
CFGS_FILES = $(wildcard *.cfg)
INC_FILES = $(wildcard *.inc)

DIR_PATH_LEN:=`dirname $(shell pwd) | wc -c`
START_IDX=$(shell expr $(DIR_PATH_LEN) + 1)
TESTNAME=`echo $(shell pwd) | cut -c $(START_IDX)-`

all: clock_gettime.c
	$(CC) $(FLAGS) $^ -o $(TARGET)

install: ${TARGET}
	mkdir -p ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 ${TARGET} ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 runtest.sh ${DESTDIR}/${PREFIX}/${TESTNAME}
	cp $(CFGS_FILES) $(INC_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}

clean:
	rm -f $(TARGET) *.o .depend *.*~

