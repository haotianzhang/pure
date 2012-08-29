
#CC=g++
SRCS=$(wildcard *.c)
TARGETS=$(patsubst %.c,%,$(SRCS))
LDFLAGS+=-pthread

all:$(TARGETS)

clean:
	rm -rf $(TARGETS)
install:
