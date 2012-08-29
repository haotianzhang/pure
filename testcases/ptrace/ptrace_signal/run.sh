#!/bin/bash

source /opt/pure/lib/function.sh

targetFullPath=/opt/pure/testcases/ptrace/ptrace_signal/target
ptrace_sigFullPath=/opt/pure/testcases/ptrace/ptrace_signal/ptrace_sig

runCount=5

# === kill all target processes  the target
function clean_env()
{
	lineNum=`ps -ef | grep $targetFullPath | wc -l`

	while [ $lineNum -gt 1 ]
	do
		pid=`ps -ef | grep $targetFullPath |  awk 'NR==1{print $2}'`
		kill -9 $pid
		lineNum=`ps -ef | grep $targetFullPath | wc -l`
	done
}


echo
echo "<TEST 5>: Trace signal test" 
echo "==========================="
echo


# === start /opt/pure/testcases/ptrace/ptrace_signal/target process

$targetFullPath &
sleep 1
pid=`ps -ef | grep $targetFullPath |  awk 'NR==2{print $2}'`


# === start the /opt/pure/testcases/bin/ptrace_sig process, collect the output to the file /tmp/signal

$ptrace_sigFullPath $pid $runCount > /tmp/signal

# === check the result, if the signal sequence is wrong, return -1. otherwise return 0.

SIGSTOP_NUM=`kill -l SIGSTOP`
SIGTRAP_NUM=`kill -l SIGTRAP`
signalCount=`cat /tmp/signal | grep signal | wc -l` 

((sCount=runCount * 2))

if [ "$signalCount" != "$sCount" ];then
echo There should be $sCount signals in this test case, but it is just $signalCount. 
clean_env
exit $TEST_RETVAL_FAIL
fi

currentLineNum=1

while [ $currentLineNum -le $signalCount ]
do
signalNum=`cat /tmp/signal | grep signal | awk 'NR=='$currentLineNum'{print $2}'`

if [ "$signalNum" != "$SIGSTOP_NUM" ];then
echo get worry signal
cat /tmp/signal 
clean_env
exit $TEST_RETVAL_FAIL
fi

((currentLineNum=currentLineNum+2))
done


currentLineNum=2

while [ $currentLineNum -le $signalCount ]
do
signalNum=`cat /tmp/signal | grep signal | awk 'NR=='$currentLineNum'{print $2}'`

if [ "$signalNum" != "$SIGTRAP_NUM" ];then
echo get worry signal
cat /tmp/signal 
clean_env
exit $TEST_RETVAL_FAIL
fi

((currentLineNum=currentLineNum+2))
done

# === cat the result and delete the template file /tmp/signal

clean_env
cat /tmp/signal
rm /tmp/signal -rf
exit $TEST_RETVAL_PASS

