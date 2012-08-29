
TARGET=process

#LIBS_FILES = $(wildcard *.sh *.class)
LIBS_FILES = $(shell find . -maxdepth 1 -type f ! -name "Makefile" ! -name "*.c" ! -name "*.cfg" ! -name "*.log" ! -name "*.inc")
CFGS_FILES = $(wildcard *.cfg)
INC_FILES = $(wildcard *.inc)
SRCS=$(wildcard *.c)

DIR_PATH_LEN:=`dirname $(shell pwd) | wc -c`
START_IDX=$(shell expr $(DIR_PATH_LEN) + 1)
TESTNAME=`echo $(shell pwd) | cut -c $(START_IDX)-`

all: process 

process:  
	$(CC) $(SRCS) -Wl,--relax -o process

install:
	mkdir -p ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot $(LIBS_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}	
	cp $(CFGS_FILES) $(INC_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}
clean:
	rm -f $(TARGET) *.o .depend *.*~

