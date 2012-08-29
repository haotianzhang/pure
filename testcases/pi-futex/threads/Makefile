#include Makefile.inc
SUBDIRS= pi_test

.PHONY : all

all:
	$(foreach SUBDIR,$(SUBDIRS),make -C $(SUBDIR);)
install:
	mkdir -p ${DESTDIR}/opt/pure/testcases/pi-futex/threads
	tar -hcpf - . | tar -C ${DESTDIR}/opt/pure/testcases/pi-futex/threads -xpf - --exclude='*.c' --exclude='Makefile*' --exclude='*.txt' --exclude='*.h'
clean:
	rm -f *~
	$(foreach SUBDIR,$(SUBDIRS),make -C $(SUBDIR) clean;)

