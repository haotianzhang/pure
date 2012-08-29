#!/bin/bash

source /opt/pure/lib/function.sh

CURRENT_DIR=$(pwd)
RET=$TEST_RETVAL_PASS


#Main entry
echo "#####################################"
echo " Start to test Ptrace system call    "
echo "#####################################"

if test X"$1" != "X"; then
	tc=`echo $1 | cut -d'_' -f 3`
	if [ $tc -lt 5 ]; then 
		TEST_DIRS="ptrace_basic"
		echo ""
		echo "Run $TEST_DIRS tests"
		echo "=============================="
		echo ""
	else 
		TEST_DIRS="ptrace_signal"
	fi
	cd $CURRENT_DIR/$TEST_DIRS
        if [ ! -x run.sh ]; then
        	chmod 755 run.sh
        fi
	./run.sh $1
        [ $? -eq 0 ] && {
                echo "########  Sub test $1: PASS  ######"
        } || {
                echo "########  Sub test $1: FAIL  ######"
		RET=$TEST_RETVAL_FAIL
        }

else
	TEST_DIRS="ptrace_basic ptrace_signal"
	for test_dir in $TEST_DIRS; do
		echo ""
		echo "Run $test_dir tests"
		echo "=============================="
		echo ""
        	cd $CURRENT_DIR/$test_dir;
	        if [ ! -x run.sh ]; then
			chmod 755 run.sh
	        fi
        	./run.sh
        	if [ $? -ne 0 ];then
	        	RET=$TEST_RETVAL_FAIL
	        fi

	done

fi
exit $RET
