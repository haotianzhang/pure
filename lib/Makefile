AFLAGS = -r
INCLUDE = -I../include

#LIBS_FILES = $(wildcard *.sh *.class)
LIBS_FILES = $(shell find . -maxdepth 1 -type f ! -name "Makefile" ! -name "*.c")
SOUCE_FILES = $(wildcard *.c)
OBJS = $(patsubst %.c,%.o,$(SOUCE_FILES))

%.o : %.c %.h
	$(CC) -c $(CFLAGS) $< -o $@ $(INCLUDE)

%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@ $(INCLUDE)

.PHONY:clean
install:
	mkdir -p ${DESTDIR}/opt/pure/lib/
	install -m 0644 $(LIBS_FILES) ${DESTDIR}/opt/pure/lib/
clean:
	$(RM) $(TARGET) $(OBJS)
