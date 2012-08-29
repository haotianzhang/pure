#include ../Makefile.inc

SRCS=$(wildcard *.c)
TARGETS=$(patsubst %.c,%,$(SRCS))
CFLAGS+=-Wall -D_GNU_SOURCE -o2 -g -I../include
LDFLAGS += -pthread

all:$(TARGETS)

clean:
	rm -rf $(TARGETS)
