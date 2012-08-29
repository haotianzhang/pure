SUBDIRS = `ls */Makefile | sed "s/Makefile//g" ` 
CFGS_FILES = $(wildcard *.cfg)
INC_FILES = $(wildcard *.inc)

DIR_PATH_LEN:=`dirname $(shell pwd) | wc -c`
START_IDX=$(shell expr $(DIR_PATH_LEN) + 1)
TESTNAME=`echo $(shell pwd) | cut -c $(START_IDX)-`

all:
	@set -e; for i in $(SUBDIRS); do $(MAKE) -C $$i ; done
clean:
	@set -e; for i in $(SUBDIRS) ; do $(MAKE) -C $$i clean ; done
	
install:
	mkdir -p ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot runtest.sh ${DESTDIR}/${PREFIX}/${TESTNAME}
	install -m0755 -oroot -groot unionfs.sh ${DESTDIR}/${PREFIX}/${TESTNAME}
	cp $(CFGS_FILES) $(INC_FILES) ${DESTDIR}/${PREFIX}/${TESTNAME}

