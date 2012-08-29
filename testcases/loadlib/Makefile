
TARGET=loadlib

#LIBS_FILES = $(wildcard *.sh *.class)
LIBS_FILES = $(shell find . -maxdepth 1 -type f ! -name "Makefile" ! -name "*.c" ! -name "*.cfg" ! -name "*.log" ! -name "*.inc" ! -name "*.o" ! -name "*.so" ! -name "mtest")
CFGS_FILES = $(wildcard *.cfg)
INC_FILES = $(wildcard *.inc)

DIR_PATH_LEN:=`dirname $(shell pwd) | wc -c`
START_IDX=$(shell expr $(DIR_PATH_LEN) + 1)
TESTNAME=`echo $(shell pwd) | cut -c $(START_IDX)-`

all: clean
	$(CC) -fPIC  -c calc.c
	$(CC) -shared -Wl,-soname,libmean-1.so -o libmean-1.so calc.o
	ln -sf libmean-1.so libmean.so
	$(CC) main.c -L$(shell pwd) -lmean -o mtest
	tar -cvzpPf ltest.tgz libmean.so libmean-1.so mtest

install:
	mkdir -p ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot $(LIBS_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}	
	cp $(CFGS_FILES) $(INC_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}

clean:
	rm -f calc.o libmean.so libmean-1.so mtest ltest.tgz
