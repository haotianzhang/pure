



RES_COL=70
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_SKIP="echo -en \\033[1;36m"
SETCOLOR_TIMEOUT="echo -en \\033[1;33m"
SETCOLOR_MANUAL="echo -en \\033[1;34m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
SETCOLOR_EXCEPTION="echo -en \\033[0;36m"
SETCOLOR_REPORT="echo -en \\033[0;35m"

DIR=`pwd`
LOGDIR="$DIR/testlog"
RESULTDIR="$DIR/testresult"
ALLNUM=0
NOTRUNNUM=0
PASSNUM=0
FAILNUM=0
SKIPNUM=0
EXCNUM=0

##TEST Case Return Value##
TEST_RETVAL_PASS=0
TEST_RETVAL_FAIL=1
TEST_RETVAL_SKIP=77
TEST_RETVAL_MANUAL=99

pass()
{
$MOVE_TO_COL #| tee -a $RESULTDIR
echo -n '[ ' #| tee -a $RESULTDIR
$SETCOLOR_SUCCESS #| tee -a $RESULTDIR
echo -n " PASSED " #| tee -a $RESULTDIR
$SETCOLOR_NORMAL #|tee -a $RESULTDIR
echo ' ]' #| tee -a $RESULTDIR
PASSNUM=`expr $PASSNUM + 1`
ALLNUM=`expr $ALLNUM + 1`
}

fail()
{
$MOVE_TO_COL  # | tee -a $RESULTDIR
echo -n '[ ' # | tee -a $RESULTDIR
$SETCOLOR_FAILURE #| tee -a $RESULTDIR
echo -n FAILED #| tee -a $RESULTDIR
$SETCOLOR_NORMAL #| tee -a $RESULTDIR
echo ' ]' #| tee -a $RESULTDIR
FAILNUM=`expr $FAILNUM + 1`
ALLNUM=`expr $ALLNUM + 1`
}

skip()
{
$MOVE_TO_COL  # | tee -a $RESULTDIR
echo -n '[ ' # | tee -a $RESULTDIR
$SETCOLOR_SKIP #| tee -a $RESULTDIR
echo -n UNTESTED #| tee -a $RESULTDIR
$SETCOLOR_NORMAL #| tee -a $RESULTDIR
echo ' ]' #| tee -a $RESULTDIR
SKIPNUM=`expr $SKIPNUM + 1`
ALLNUM=`expr $ALLNUM + 1`
}

#For the runtest.sh, when ret value was 88.
#The test was killed by ./bin/operation_progress.sh.
#But the board can continue to run the following cases.
timeout()
{
$MOVE_TO_COL  # | tee -a $RESULTDIR
echo -n '[ ' # | tee -a $RESULTDIR
$SETCOLOR_TIMEOUT #| tee -a $RESULTDIR
echo -n Time_Out #| tee -a $RESULTDIR
$SETCOLOR_NORMAL #| tee -a $RESULTDIR
echo ' ]' #| tee -a $RESULTDIR
EXCNUM=`expr $EXCNUM + 1`
ALLNUM=`expr $ALLNUM + 1`
}

#For the runtest.sh, when ret value was 99.
#The test should not to be run in the mail loop.
manual()
{
$MOVE_TO_COL  # | tee -a $RESULTDIR
echo -n '[ ' # | tee -a $RESULTDIR
$SETCOLOR_MANUAL #| tee -a $RESULTDIR
echo -n Should be executed manually #| tee -a $RESULTDIR
$SETCOLOR_NORMAL #| tee -a $RESULTDIR
echo ' ]' #| tee -a $RESULTDIR
EXCNUM=`expr $EXCNUM + 1`
ALLNUM=`expr $ALLNUM + 1`
}

#For the runtest.sh, when ret value was unpredictive.
#The test 
exception()
{
[ -e $1.kill ] && timeout || {
		$MOVE_TO_COL  # | tee -a $RESULTDIR
		echo -n '[ ' # | tee -a $RESULTDIR
		$SETCOLOR_EXCEPTION #| tee -a $RESULTDIR
		echo -n Exception_Occured #| tee -a $RESULTDIR
		$SETCOLOR_NORMAL #| tee -a $RESULTDIR
		echo ' ]' #| tee -a $RESULTDIR
		EXCNUM=`expr $EXCNUM + 1`
		ALLNUM=`expr $ALLNUM + 1`
	}
}

#Following define is for subcase return value
subcase_pass()
{
    return $TEST_RETVAL_PASS
}


subcase_fail()
{
    return $TEST_RETVAL_FAIL
}


subcase_skip()
{
    return $TEST_RETVAL_SKIP
}


subcase_manual()
{
    return $TEST_RETVAL_MANUAL
}

