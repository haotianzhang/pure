#!/bin/bash

source /opt/pure/lib/function.sh

TEST_RESULT=49995000
RET=0

if [ -f process ]; then
	./process | tee LargeTextApp_result.log 
	RESULT=`cat LargeTextApp_result.log`
	if [ $RESULT -ne $TEST_RESULT ];then
		echo "LargeTextApp test FAILED";
		RET=$TEST_RETVAL_FAIL
	else
		echo "LargeTextApp test PASS";
		RET=$TEST_RETVAL_PASS
	fi
else
	echo "LargeTextApp could not be found in the target"
	RET=$TEST_RETVAL_SKIP
fi

exit $RET

