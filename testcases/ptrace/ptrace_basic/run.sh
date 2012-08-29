#!/bin/bash

source /opt/pure/lib/function.sh
TC_PATH=`dirname $0`
TC_SCRIPT=`basename $0`

passed_tests=0
failed_tests=0
skipped_tests=0

function do_test_1
{
	echo
	echo "<TEST 1>: Trace system call" 
	echo "==========================="
	echo
	test_name=$TC_PATH/ptrace_test
	[ -f $test_name ] && echo testing... 
	if [ ! -x $test_name ]; then
		chmod 755 $test_name
	fi
	
	./$test_name
	ret=$?
	if [ ${ret} -eq 0 ]; then
		passed_tests=`expr $passed_tests + 1`
		echo 
		echo "******** PASSED! ********"
		echo
		return $TEST_RETVAL_PASS
	elif [ ${ret} -eq 2 ]; then
		skipped_tests=`expr $skipped_tests + 1`
		echo 
		echo "******** SKIPPED! ********"
		echo 
		return $TEST_RETVAL_SKIP
	else
		failed_tests=`expr $failed_tests + 1`
		echo
		echo "******** FAILED! ********"
		echo
		return $TEST_RETVAL_FAIL
	fi
}

function do_test_2
{
	echo
	echo
	echo "<TEST 2>: Singlestep test" 
	echo "==========================="
	echo
	test_name=$TC_PATH/single-step
	test_name_2=$TC_PATH/dummy2
	if [ ! -x $test_name ]; then
		chmod 755 $test_name
		chmod 755 $test_name_2
	fi
	cd $TC_PATH
	./single-step
	ret=$?
	cd -
	if [ $ret -eq 0 ]; then
		passed_tests=`expr $passed_tests + 1`
		echo 
		echo "******** PASSED! ********"
		echo
		return $TEST_RETVAL_PASS
	elif [ $ret -eq 2 ]; then
		skipped_tests=`expr $skipped_tests + 1`
		echo 
		echo "******** SKIPPED! ********"
		echo
		return $TEST_RETVAL_SKIP
	else
		failed_tests=`expr $failed_tests + 1`
		echo
		echo "******** FAILED! ********"
		echo
		return $TEST_RETVAL_FAIL
	fi
}

function do_test_3
{
	echo
	echo
	echo "<TEST 3>: Stop test" 
	echo "==========================="
	echo
	test_name=$TC_PATH/ptrace-stop-test.exp
	test_name_2=$TC_PATH/stop
	test_name_3=$TC_PATH/test-stop.sh
	test_name_4=$TC_PATH/dummy
	if [ ! -x $test_name ]; then
		chmod 755 $test_name
		chmod 755 $test_name_2
		chmod 755 $test_name_3
		chmod 755 $test_name_4
	fi
	whereis expect || exit $TEST_RETVAL_SKIP
	cd $TC_PATH
	./ptrace-stop-test.exp test-stop.sh
	ret=$?
	cd -
	if [ $ret -eq 0 ]; then
		passed_tests=`expr $passed_tests + 1`
		echo 
		echo "******** PASSED! ********"
		echo
		return $TEST_RETVAL_PASS
	elif [ $ret -eq 2 ]; then
		skipped_tests=`expr $skipped_tests + 1`
		echo 
		echo "******** SKIPPED! ********"
		echo
		return $TEST_RETVAL_SKIP
	else
		failed_tests=`expr $failed_tests + 1`
		echo
		echo "******** FAILED! ********"
		echo
		return $TEST_RETVAL_FAIL
	fi
}

function do_test_4
{
        echo
        echo
        echo "<TEST 4>: Trace system call test" 
        echo "==========================="
        echo
        test_name=$TC_PATH/ptrace-test
        if [ ! -x $test_name ]; then
                chmod 755 $test_name
        fi

        $test_name
        ret=$?
        if [ $ret -eq 0 ]; then
                passed_tests=`expr $passed_tests + 1`
                echo 
                echo "******** PASSED! ********"
                echo
                return $TEST_RETVAL_PASS
        elif [ $ret -eq 2 ]; then
                skipped_tests=`expr $skipped_tests + 1`
                echo 
                echo "******** SKIPPED! ********"
                echo 
                return $TEST_RETVAL_SKIP
        else
                failed_tests=`expr $failed_tests + 1`
                echo
                echo "******** FAILED! ********"
                echo
                return $TEST_RETVAL_FAIL
        fi

}


#main loop entry

if test X"$1" != "X"; then
        echo "########  Sub test $1: Start to test  ######"
        $1 && {
                echo "########  Sub test $1: PASS  ######"
        } || {
                echo "########  Sub test $1: FAIL  ######"
        }

else
        subcase="do_test_1 do_test_2 do_test_3 do_test_4"
        for i in $subcase; do
                echo "########  Sub test $i: Start to test  ######"
                $i && {
                        echo "########  Sub test $i: PASS  ######"      
                } || {
                        echo "########  Sub test $i: FAIL  ######"
                }
        done

fi


echo "==========================="
echo "TOTAL: $(expr $passed_tests + $skipped_tests + $failed_tests)"
echo "PASSED: $passed_tests"
echo "FAILED: $failed_tests"
echo "SKIPPED: $skipped_tests"

if [ $failed_tests -gt 0 ]; then
	exit $TEST_RETVAL_FAIL
else
	exit $TEST_RETVAL_PASS
fi
