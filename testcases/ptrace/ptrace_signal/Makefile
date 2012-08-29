

all: ptrace_sig target

clean:
	rm -rf ptrace_sig target
install:
	mkdir -p ${DESTDIR}/${PREFIX}/ptrace/ptrace_signal
	install -m0755 -oroot -groot ptrace_sig  target ${DESTDIR}/${PREFIX}/ptrace/ptrace_signal
	install -m0755 -oroot -groot run.sh README ${DESTDIR}/${PREFIX}/ptrace/ptrace_signal
