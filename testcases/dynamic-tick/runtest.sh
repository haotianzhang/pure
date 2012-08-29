#!/bin/bash

TC_PATH=`dirname $0`
TC_SCRIPT=`basename $0`
source /opt/pure/lib/function.sh

KERNEL_VERSION=`uname -a| cut -d' ' -f 3`

function pre_environment_check
{
        [ -e $TC_PATH/config ] && rm $TC_PATH/config
        [ -r /proc/config.gz -o -r /boot/config-$KERNEL_VERSION ] || {
                echo "FATAL: missing file /proc/config.gz"
                exit $TEST_RETVAL_FAIL
        }
        [ -d /proc ] || {
                echo "FATAL: missing /proc directory"
                exit $TEST_RETVAL_FAIL
        }
        which gunzip >& /dev/null || {
                echo "FATAL: gunzip not found"
                exit $TEST_RETVAL_FAIL
        }
}


function generate_kernel_cfg
{
        pre_environment_check
        [ -r /proc/config.gz ] && cp /proc/config.gz $TC_PATH/ && gunzip $TC_PATH/config.gz
        [ -r /boot/config-$KERNEL_VERSION ] && cp /boot/config-$KERNEL_VERSION $TC_PATH/config
}

function config_test
{
	generate_kernel_cfg
        grep "^CONFIG_NO_HZ=y" $TC_PATH/config -q || exit $TEST_RETVAL_SKIP
	[ -f /proc/timer_list ] || exit $TEST_RETVAL_SKIP
	HZ=`cat $TC_PATH/config | grep "^CONFIG_HZ=" | awk -F"=" '{print $2}'`
	if test X"$HZ" != "X"; then
	     NO_HZ_HOLD=$HZ
	else
	     NO_HZ_HOLD=250
	fi
	return $TEST_RETVAL_PASS
}


jiffies_MAX=$((1<<32))

declare -i -x FAILS=0



# Test system tick

# Functions
# Read jiffies from /proc/timer_list
read_jiffies()
{
    awk '$1~/^jiffies:/{print $2;exit}' /proc/timer_list
}

# Read .last_jiffies .next_jiffies and jiffies from /proc/timer_list, take the first non-zero value pair.
read_separate_ji()
{
    awk 'BEGIN{lj=0;nj=0;ji=0};$1~/^.last_jiffies/{if(lj==0)lj=$3;next};$1~/^.next_jiffies/{if(nj==0&&lj>0){if($3>0)nj=$3;else lj=0;}next};$1~/^jiffies:/{if(ji==0)ji=$3;next};END{print lj,nj,ji}' /proc/timer_list
}

# get next_jiffies-last_jiffies and jiffies
read_period_ji()
{
	read last_jiffies next_jiffies jiffies <<<$(read_separate_ji)
	# period_jiffies must >=1
	(( period_jiffies=next_jiffies?next_jiffies-last_jiffies:1 ))
	(( period_jiffies<0 )) && (( period_jiffies+=jiffies_MAX ))
	echo $period_jiffies $jiffies
}

# Test dynamic tick using /proc/timer_list
test_proc_timer_list()
{
	Total=0
		
	# Get system HZ by counting jiffies in 10s period
	jiffies_BEGIN=$(read_jiffies)
	sleep 10
	jiffies_END=$(read_jiffies)
	(( HZ=(jiffies_END>jiffies_BEGIN)?(jiffies_END-jiffies_BEGIN)/10:(jiffies_END-jiffies_BEGIN+$jiffies_MAX)/10 ))
	(( HZ=(HZ+3)/10*10 ))
	echo "HZ :" $HZ
	echo -n "Dynamic Ticks :"
	#get dynamic HZ by reading CPU timer period
	for j in {1..6}
	do  period_ji=0
		for i in {1..3}
		do read pe ji <<<$(read_period_ji)
		   ((period_ji+=pe))
		   sleep 1
		done
		(( noHZ=HZ*i/period_ji ))
		printf "%5d " $noHZ
		# if dynamic HZ > HZ then failed
		if (( noHZ>HZ ));then
		    return $TEST_RETVAL_FAIL
		fi
		((j==6))||sleep 10
	done
	echo
	return $TEST_RETVAL_PASS
}


# get timer interrupts number from /proc/interrupts
# take CPU0 as sample
# take the first nonzero and increased timer interrupts,(not very reliable,need fix when meet exception)
readTicks()
{
    { grep -i " timer" /proc/interrupts||grep -i "counter" /proc/interrupts; }|awk -v nroll=$1 'BEGIN{ticks=0;if(nroll=="")nroll=0};{if($2 > 0){if(nroll>0)nroll--;else{ticks=$2;exit}}};END{print ticks;if(NR==0||ticks==0||nroll>0){exit 1}}'
}

# get dynamic ticks from interrupts number of timer in 4s period
# 
test_proc_interrupt()
{
	Total=0
	tnext=0
	# if work in Hypervisor
	ishv=$(awk '/^model name/{if($0 ~ /Hypervisor/){print 1}else{print 0}exit}'  /proc/cpuinfo)
	#get online cpu numbers
	Numcpu=$(awk 'BEGIN{num=0};/^processor/{if($3>num)num=$3};END{print num+1}' /proc/cpuinfo)
	
	i=1
	while (( i <= 10 ))
	do
		LAST_TICKS=$(readTicks $tnext) || { echo "No timer interrupt in /proc/interrupts";return $TEST_RETVAL_PASS; }
		sleep 10
		CURRENT_TICKS=$(readTicks $tnext)
		if [[ $CURRENT_TICKS == $LAST_TICKS ]];then
			((tnext++))
			continue
		fi
		Freq=$(( (CURRENT_TICKS-LAST_TICKS)/10 ))
		if [[ $ishv == 1 ]];then
			Freq=$(( Freq/Numcpu ))
		fi
		Total=$(( Total+Freq ))
		echo "$i: $LAST_TICKS ~ $CURRENT_TICKS"
		printf "  Frequence of ticks is %d Hz\n" $Freq
		((i==10)) || sleep 10
		((i++))
	done
	Avg=$((Total/10))
   
	echo
	NO_HZ_HOLD=$HZ
	if (($Avg>$NO_HZ_HOLD)); then
		printf "FAIL: average ticks %dHz over threshold %dHz\n" $Avg ${NO_HZ_HOLD}
		echo " - Please check the tickless (NO_HZ config) feature"
		return $TEST_RETVAL_FAIL
	else
		printf "PASS: average ticks %dHz under threshold %dHz\n" $Avg ${NO_HZ_HOLD}
	fi
	return $TEST_RETVAL_PASS
}

nohz_mode=$(awk '$1~/^.nohz_mode/{print $3;exit}' /proc/timer_list)
echo "nohz_mode : $nohz_mode"

function system_tick_timer_list_test
{
	if (( nohz_mode == 0 ));then
		echo "noHZ didn't enable,please check the tickless (NO_HZ config) feature"
		echo "Bypass dynamic tick test."
	else
		if (( nohz_mode != -1 ));then
			test_proc_timer_list || { 
			((FAILS++))
			echo "FAILED on test_proc_timer_list"
			return $TEST_RETVAL_FAIL
			}
		fi
	fi
	return $TEST_RETVAL_PASS
}

function system_tick_interrupts_timer_test
{
	if (( nohz_mode == 0 ));then
		echo "noHZ didn't enable,please check the tickless (NO_HZ config) feature"
		echo "Bypass dynamic tick test."
	else
		test_proc_interrupt || {
		((FAILS++))
		echo "FAILED on test_proc_interrupt"
		return $TEST_RETVAL_FAIL
		}	
	fi
	return $TEST_RETVAL_PASS
}

# Timing tests, to see if timming function of the sytem works fine with noHz on
function dynamic_tick_timing_function_test
{
	if [[ -x $TC_PATH/dyntick-test ]]; then
	    echo "Running timing tests ..."
	    $TC_PATH/dyntick-test | awk 'BEGIN{nerr=0;nok=0};{if($NF=="ERROR"){nerr++;printf "*"}else if($NF=="OK"){nok++};print};END{if(nerr>0){printf "\nTotal %d tests failed\n",nerr;exit 1}else if(nok==0){print "Fail to run test";exit 1}}' || { echo "Time test FAILED";((FAILS++)); }
	else
	    echo "No executable dyntick-test. Bypass timing test"
	fi
}

# exit entry
function exit_test
{

	if ((FAILS > 0));then
		echo "###### dynamic tick failed ######"
		exit $TEST_RETVAL_FAIL
	fi
	exit $TEST_RETVAL_PASS
}


#### main loop

echo "######  Start to test dynamic ticks  ######"
########  Config test :
echo "########  Sub test config: Start to config  ######"
config_test && { 
	echo "########  Sub test config: PASS  ######"
} || {
	echo "########  Sub test config: FAIL  ######"
}


if test X"$1" != "X"; then
	echo "########  Sub test $1: Start to test jiffies via proc/`echo $1|cut -d'_' -f 3,4`  ######"
	$1_test && {     
        	echo "########  Sub test $1: PASS  ######"
	} || {
        	echo "########  Sub test $1: FAIL  ######"
	}

else
	subcase="system_tick_timer_list system_tick_interrupts_timer dynamic_tick_timing_function"
	for i in $subcase; do
		echo "########  Sub test $i: Start to test jiffies via proc/`echo $1|cut -d'_' -f 3,4`  ######"
		$i\_test && {
			echo "########  Sub test $i: PASS  ######"	
	        } || {
                	echo "########  Sub test $i: FAIL  ######"
        	}
	done

fi

exit_test


