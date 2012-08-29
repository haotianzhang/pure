
#SUBDIRS := $(shell if [ -x "$$ENABLED_Kfeatures" ]; then echo $$ENABLED_Kfeatures)
PWD = $(shell pwd)
#PKGCONFIG = $(shell find ../../host-cross/*-wrs-linux-* -name pkgconfig | grep lib/pkgconfig)
#SUBDIRS = $(shell find testcases/ -maxdepth 2 -name *.inc| xargs grep "TEST=enabled" | awk -F"/"  '{print $$2}')
#SUBDIRS = $(shell ls ./testcases/)

# Default installation directory for testing cases by Pure suite.
PREFIX  = /opt/pure/testcases
export PREFIX

all:
	@./gen-test-matrix.sh ${LINUX_DISTRO} ${KERNEL_PATH}/meta/cfg/scratch ${BSP_NAME}
	@ SUBDIRS=`find testcases/ -maxdepth 2 -name *.inc| xargs grep "TEST=enabled" | awk -F"/"  '{print $$2}'`; \
	for i in $$SUBDIRS; do echo "Start to make $$i"; \
		${MAKE} -C testcases/$$i ;\
	done
clean:
	@./gen-feature-matrix.sh ${LINUX_DISTRO} ${KERNEL_PATH}/meta/cfg/scratch ${BSP_NAME} \
	@ SUBDIRS=`find testcases/ -maxdepth 2 -name *.inc| xargs grep "TEST=enabled" | awk -F"/"  '{print $$2}'`; \
	for i in $${SUBDIRS} ; do echo "Start to cleanup $$i"; \
	if [ -f testcases/$i/Makefile ]; then \
		$(MAKE) -C testcases/$$i clean ; \
	else \
		echo "Skip to cleanup test cases in $$i"; \
	fi; \
	done
install:
	
	${MAKE} -C lib install
	${MAKE} -C bin install
	@ SUBDIRS=`find testcases/ -maxdepth 2 -name *.inc| xargs grep "TEST=enabled" | awk -F"/"  '{print $$2}'`; \
	for i in $$SUBDIRS; do echo "Start to install $$i"; \
		${MAKE} -C testcases/$$i install; \
	done
	install -m0755 main_test.sh ${DESTDIR}/opt/pure/
	install -m0644 test_cases.matrix ${DESTDIR}/opt/pure/
	install -d ${DESTDIR}/opt/pure/testcases/bin
