#!/bin/bash

source /opt/pure/lib/function.sh

#test if the SCHED_DEADLINE option has been openned.
CONFIG=`zcat /proc/config.gz | grep SCHED_DEADLINE | awk -F"=" '{print $2}'`

if test X"$CONFIG" != "Xy"; then
	echo "SCHED_DEADLINE didn't open, skip this testing!"
	exit $TEST_RETVAL_FAIL #skip this testing.
fi

which schedtool
if test $? != "0"; then
	echo "didn't install schedtool, skip this testing!"
	exit $TEST_RETVAL_SKIP
fi

if test -e /proc/sys/kernel/sched_dl_period_us ; then
	echo "the file /proc/sys/kernel/sched_dl_period_us is existing!"
else
	echo "the file /proc/sys/kernel/sched_dl_period_us is missing!"
	exit $TEST_RETVAL_SKIP
fi

if test -e /proc/sys/kernel/sched_dl_runtime_us; then
	echo "the file /proc/sys/kernel/sched_dl_runtime_us is existing!"
else
	echo "the file /proc/sys/kernel/sched_dl_runtime_us is missing!"
	exit $TEST_RETVAL_SKIP
fi

bandwidth=0

period_us=`more /proc/sys/kernel/sched_dl_period_us`
runtime_us=`more /proc/sys/kernel/sched_dl_runtime_us`

period_us=`expr $period_us / 100`
bandwidth=`expr $runtime_us / $period_us`
echo bandwidth=$bandwidth

if test $bandwidth == "5"; then
	killall yes
	sleep 1
	schedtool -E -t 500:10000 -e yes >/dev/null 2>&1 &
	PID=`ps aux >ps.tmp; cat ps.tmp | grep yes | awk '{print $2}'`
#	rm -rf ps.tmp
	sleep 5 
	#top -p $PID >top.log &
	COUNT=0
	echo >cpu_percent.log
	total=0
	while (( $COUNT < 1000 )); do
		COUNT=`expr $COUNT + 1`
		ps auxw >ps.log
		count=`cat ps.log | grep $PID | awk '{print $3}'`
		echo count=$count
		echo total=$total
		total=`awk "BEGIN{print $total+$count}"`
	done
	killall yes

	total=`awk "BEGIN{print $total*10}"`
	avg=`expr $total / 1000`
	echo avg=$avg	
	if [[ $avg -gt 40 && $avg -lt 60 ]] ; then	
		echo "testing PASS"
	#	exit 0
	else
		echo "testing FAIL"
		exit $TEST_RETVAL_FAIL
	fi

	killall yes
	sleep 1
	schedtool -E -t 300:10000 -e yes >/dev/null 2>&1 &
        PID=`ps aux >ps.tmp; cat ps.tmp | grep yes | awk '{print $2}'`
        #rm -rf ps.tmp
        sleep 5
        #top -p $PID >top.log &
        COUNT=0
        echo >cpu_percent.log
        total=0
        while (( $COUNT < 1000 )); do
                COUNT=`expr $COUNT + 1`
                ps auxw >ps.log
                count=`cat ps.log | grep $PID | awk '{print $3}'`
                echo count=$count
                echo total=$total
                total=`awk "BEGIN{print $total+$count}"`
        done
        killall yes

        total=`awk "BEGIN{print $total*10}"`
        avg=`expr $total / 1000`
        echo avg=$avg   
        if [[ $avg -gt 20 && $avg -lt 40 ]] ; then
                echo "testing PASS"
        #       exit 0
        else
                echo "testing FAIL"
                exit $TEST_RETVAL_FAIL
        fi

	##################################################
	#clean the log files
	##################################################
	rm -rf ps.log cpu_percent.log

	############################
	#testing cgroup sched_dl
	############################
	if test -e  /cgroup ; then
		echo "/cgroup dirctory existing!"
	else
		mkdir /cgroup
	fi
	tag=`mount | grep cgroup | wc -l`
	if test $tag == "1"; then
		umount -t cgroup nodev
	fi 
	mount -t cgroup none /cgroup/
	if test $? != 0; then
		echo "mount cgroup failed!"
		exit 77
	fi

	cd /cgroup
	mkdir A
	cd A
	echo 0 > cpuset.cpus
	echo 0 > cpuset.mems
	echo 20000 > cpu.dl_runtime_us
	sleep 1
	yes > /dev/null 2>&1 &
	cd ~/
	PID=`ps aux >ps.tmp; cat ps.tmp | grep yes | awk '{print $2}'`
	rm -rf ps.tmp

	echo $PID > tasks
	
	
	schedtool -E -t 200:10000 $PID
        sleep 5
        COUNT=0
        echo >cpu_percent.log
        total=0
        while (( $COUNT < 1000 )); do
                COUNT=`expr $COUNT + 1`
                ps auxw >ps.log
                count=`cat ps.log | grep $PID | awk '{print $3}'`
                echo count=$count
                echo total=$total
                total=`awk "BEGIN{print $total+$count}"`
        done
        killall yes
	rm -rf cpu_percent.log ps.log
	rmdir /cgroup/A
	umount /cgroup
        total=`awk "BEGIN{print $total*10}"`
        avg=`expr $total / 1000`
        echo avg=$avg   
        if [[ $avg -gt 10 && $avg -lt 30 ]] ; then
                echo "testing PASS"
        #       exit 0
        else
                echo "testing FAIL"
                exit $TEST_RETVAL_FAIL
        fi

	echo "############################################"
	echo "  schedtool and sched_dl testing PASS"
	echo "############################################"
	exit $TEST_RETVAL_PASS
fi


