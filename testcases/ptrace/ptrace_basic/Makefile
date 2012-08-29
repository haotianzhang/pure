
SRCS=$(wildcard *.c)
TARGETS=$(patsubst %.c,%,$(SRCS))

all:$(TARGETS)

clean:
	rm -rf $(TARGETS)
install:
	mkdir -p ${DESTDIR}/${PREFIX}/ptrace/ptrace_basic
	tar -hcpf - . | tar -C ${DESTDIR}/${PREFIX}/ptrace/ptrace_basic -xpf - --exclude='*.c' --exclude='Makefile*' --exclude='*.txt'
