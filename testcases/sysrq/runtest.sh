#!/bin/sh
#
# Copyright (c) 1995-2006, 2007, 2008, 2009, 2012 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#
# Summary:
# =================================================
# 1. Smart way test : (must be run)
#    ---------
#    echo 'm' > /proc/sysrq-trigger
#    ---------
# 2. Test via serial console : (select to run)
#    Check "console=ttyS0,115200" adding in cmdline. 
#  A.For minicom, connect via serial port directly.(manual)
#    The command sequence: 'ctrl+a f' will initiate a break sequence.  
#    ---------
#    ctrl+a f
#    m
#    ---------
#  B.For telnet, connect via terminal server.
#    This test can detect "WIND00192574 Fail to use SysRq over a serial console".
#    ---------
#    ctrl+]
#    telnet> send brk
#    m
#    ---------
# 3. Keyboard+screen console: (select to run)
#    The board on desk, test it using this way.
#    For this case, should redo dotest2 manually,
#      'echo 0\1 > /proc/sys/kernel/sysrq/' enable or disable sysrq, 
#      check it function by press key combo
#    Press the key combo 'ALT-SysRq-<command key>'
#    ---------
#    ALT-SysRq-m
#    ---------
# Logs show:
#    SysRq : Show Memory
#


TESTNAME="sysrq"
TESTROOT=${TESTROOT:="pure/testcases"}
source /opt/pure/lib/function.sh
#================================================

PASSNUM=0
FAILNUM=0
SKIPNUM=0 
TOTALNUM=4

TESTCOMMENT=
KLOG_BEGIN="/opt/${TESTROOT}/${TESTNAME}/klog/klog_begin"
KLOG_END="/opt/${TESTROOT}/${TESTNAME}/klog/klog_end"
KLOG_RUNTIME="/opt/${TESTROOT}/${TESTNAME}/klog/klog_runtime"
KLOG_PATH="`dirname ${KLOG_BEGIN}`"
#===============================================
#
# caseStart print case start time and case name.
#
caseStart() {
cat <<EOF
--------------------------------------------
Name:   $1
Date:   `date`

EOF
}

#
# caseEnd print case end time and result.
#
caseEnd() {
cat <<EOF
--------------------------------------------
Name:   $1 `[ $2 -eq $TEST_RETVAL_PASS ] && echo -e "\t\tPASS" || echo -e "\t\tFAIL"`
Date:   `date`
Desc:   $TESTCOMMENT

EOF
}


klog_begin() # booting log
{
    dmesg > $KLOG_BEGIN
}

klog_end() # runtime log
{
    dmesg | sed -e '1d' > $KLOG_END
    diff $KLOG_BEGIN  $KLOG_END | grep '^> ' | sed 's/> \(.*\)/\1/' > $KLOG_RUNTIME 
}

klog_backup()
{
    echo "klog begin backup $1 " > /dev/null 
    [ -e $KLOG_BEGIN ] && cp -rf $KLOG_BEGIN  $KLOG_PATH/klog_begin$1 
}

klog_recover()
{
    echo "klog begin recover $1 "  > /dev/null
    [ -e $KLOG_PATH/klog_begin$1 ] && cp -rf $KLOG_PATH/klog_begin$1 $KLOG_BEGIN  
}

#===============================================

dotest1()
{
    TESTCOMMENT="Check Magic SysRq config"
    if !(cat ~/config | grep CONFIG_MAGIC_SYSRQ=y) ; then
	    echo "CONFIG_MAGIC_SYSRQ=y NOT be set"
        return $TEST_RETVAL_FAIL
    fi
    PASSNUM=$(($PASSNUM + 1))
    return $TEST_RETVAL_PASS
}

dotest2()
{
# Note that the value of /proc/sys/kernel/sysrq influences only the invocation
# via a keyboard. Invocation of any operation via /proc/sysrq-trigger is always
# allowed (by a user with admin privileges).

    TESTCOMMENT="Enable and Disable Magic Sysrq key"
    for ((index=1; index<=2; index++)); do
	    KEY=`cat /proc/sys/kernel/sysrq`
	    if [ $KEY -eq 0 ] ; then
		    echo "Magic sysrq has been disabled" 
		    echo 1 > /proc/sys/kernel/sysrq
		    [ $? -eq 0 ] || {       
			    echo " 'echo 1 > sysrq' Enable Magic Sysrq failed"
                return $TEST_RETVAL_FAIL
		    }
		    N_key=`cat /proc/sys/kernel/sysrq`
		    [ $N_key -ne $KEY ] || {
			    echo " 'echo 1 > sysrq' Enable Magic Sysrq value judge failed"
                return $TEST_RETVAL_FAIL
		    }
	    else
		    echo "Magic sysrq has been enabled"
		    echo 0 > /proc/sys/kernel/sysrq
		    [ $? -eq 0 ] || {       
			    echo " 'echo 0 > sysrq' Disable Magic Sysrq failed"
                return $TEST_RETVAL_FAIL
		    }
		    N_key=`cat /proc/sys/kernel/sysrq`
		    [ $N_key -ne $KEY ] || {
			    echo " 'echo 0 > sysrq' Disable Magic Sysrq value judge failed"
                return $TEST_RETVAL_FAIL
		    }
	    fi
    done
    PASSNUM=$(($PASSNUM + 1))
    return $TEST_RETVAL_PASS
}

dotest3()
{
    TESTCOMMENT="Check dump current memory info"
    klog_begin
    if !(echo m > /proc/sysrq-trigger) ; then
	    echo "'echo m > sysrq' dump current meminfo failed"
        return $TEST_RETVAL_FAIL
    else
        klog_end
	    [ -s $KLOG_RUNTIME ] || return $TEST_RETVAL_FAIL
        cat $KLOG_RUNTIME
	    if !(cat $KLOG_RUNTIME | grep 'SysRq : Show Memory') ; then
		    echo "grep 'SysRq : Show Memory' in dmesg failed"
            return $TEST_RETVAL_FAIL
	    fi
    fi
    PASSNUM=$(($PASSNUM + 1))
    return $TEST_RETVAL_PASS
}

dotest4()
{
    TESTCOMMENT="Dump the current registers and flags"
    klog_begin
    if !(echo p > /proc/sysrq-trigger) ; then
	echo "'echo p > sysrq' dump current meminfo failed"
        return $TEST_RETVAL_FAIL
    else
        klog_end
	    [ -s $KLOG_RUNTIME ] || return $TEST_RETVAL_FAIL
        cat $KLOG_RUNTIME
	    if !(cat $KLOG_RUNTIME | grep 'SysRq : Show Regs') ; then
		    echo "grep 'SysRq : Show Regs' in dmesg failed"
            return $TEST_RETVAL_FAIL
	    fi
    fi
    PASSNUM=$(($PASSNUM + 1))
    return $TEST_RETVAL_PASS
}

#===============================================
if [ ! -d ${KLOG_PATH} ]; then 
mkdir -p ${KLOG_PATH}
fi

RET=
klog_begin
klog_backup 0

SUBCASERUN="$1"
if [ "X$SUBCASERUN" != X ] ;then
        TOTALNUM=1
        caseStart $SUBCASERUN 
        $SUBCASERUN
        RET=$?
        caseEnd $SUBCASERUN $RET
        [ $RET -eq $TEST_RETVAL_FAIL ] && FAILNUM=$(($FAILNUM + 1))
else
        for ((i=1;i<=TOTALNUM;i++));do
            caseStart dotest${i}
            dotest${i}
            RET=$?
            caseEnd dotest${i} $RET
            [ $RET -eq $TEST_RETVAL_FAIL ] && FAILNUM=$(($FAILNUM + 1))
        done
fi

klog_recover 0

[ 0 -ne $FAILNUM ] && exit $TEST_RETVAL_FAIL
[ $TOTALNUM -ne $PASSNUM ] && exit $TEST_RETVAL_FAIL
exit $TEST_RETVAL_PASS
