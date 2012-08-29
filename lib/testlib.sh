#! /bin/bash
#
# Definition of class run_test for the multi special test cases in pure
#
# Copyright (c) 2008-2012, WindRiver CDC Linux Testing Team
#
# <zhengwang.ruan@windriver.com>
# <Guojian.Zhou@windriver.com>
#
# Version 1.0 
#

source lib/run_test.class
source lib/lib.sh
source lib/records.class
source lib/function.sh

QUIET_FLAG=0 

printUsage ()
{
    cat <<-EOF >&1
    usage: ./${0##*/} [-a] [-c] [-f filename] [-l] [-p] [-q] [-t] [-s test1,test2,...] [-v test1,test2,...] [-h]
    -a : Run all test case
    -c : Continue run the rest test case
    -D : Delet the test logs in the test cases
    -f filename : Run all test cases which list in the filename.
    -t : Report the testresult
    -l : Collect all test cases log to /opt/pure/logs/log
    -p : Display all test cases
    -q : Quiet run test case
    -s testcase1,testcase2,... : Select testcase1 , testcase2 ...
    -x testcase1:subcase1 : Select testcase1's subcase1
    -v testcase1,testcase2,... : Skip testcase1 , testcase2 ...
    -h : Print this menu
    example: ./${0##*/} -a : Run all test cases.
    example: ./${0##*/} -c : only run the rest test cases.
    example: ./${0##*/} -D : Delet the test logs in the test cases.
    example: ./${0##*/} -f filename : only run the test case in the filename.
    example: ./${0##*/} -s testcase1,testcase2 : only run the selected test cases testcase1 testcase2.
    example: ./${0##*/} -x testcase1:subcase1 : only run testcase1's subcase1
    example: ./${0##*/} -v testcase1,testcase2 : skip the testcase1 and testcase2, only run the rest test cases.
    example: ./${0##*/} -p : only print all test cases, and do not run these test case .
    example: ./${0##*/} -q : only quiet run test case.
    example: ./${0##*/} -l : only collect all test cases logs.
    example: ./${0##*/} -t : print the test result.
EOF
    exit 0
}

printTestCaseName ()
{
        echo -e ""
	echo -e "\t>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo -e "\tThe test case list : "
        TEST="`echo $TEST | xargs`"
        echo -e "\t $TEST"
        echo -e "\t<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo -e ""
}

optEnabled ()
{
	local opt=$1
	local list=$2
	
	local enlb=`echo $list | sed -n "/$opt/p"`
	
	echo -e $enlb
}

HIGHPRI_OPTS=""
LOWPRI_OPTS=""

addHighPriOpt ()
{
	local opt=$1
	HIGHPRI_OPTS="$HIGHPRI_OPTS $opt"
}

addLowPriOpt ()
{
	local opt=$1
	LOWPRI_OPTS="$LOWPRI_OPTS $opt"
}

optionParse ()
{
## Options
        while getopts 'acDf:v:s:x:lpqth?' arg
        do
                case $arg in
                'a')
                        addLowPriOpt "a" ;;
                'c')
                        addLowPriOpt "c"
                        CONTINUE_FLAG=${OPTARG};;
                'D')
                        addHighPriOpt "D" ;;
                'f')
                        addLowPriOpt "f"
                        TESTSET_FILENAME=${OPTARG} ;
                        TESTS_INFILE=`cat $TESTSET_FILENAME | xargs`;;
                'v')
                        addLowPriOpt "v"
                        TESTS_TOEXCLUDE=${OPTARG} ;;
                's')
                        addLowPriOpt "s"
                        TESTS_SELECTED=${OPTARG} ;;
                'x')
                        addLowPriOpt "x"
                        TEST_SUBCASE=${OPTARG} ;;
                'l')
                        addHighPriOpt "l" ;;
                'p')
                        addHighPriOpt "p" ;;
                'q')
                        addLowPriOpt "q" ;;
                't')
                        addHighPriOpt "t"
                        REPORT=${OPTARG} ;;
                'h')
                        addHighPriOpt "h" ;;
                '?')
                        addHighPriOpt "?" ;;
                '*')
                        echo -e "\tUnknow options" ;
                        print_usage ;;
        esac
        done 
}

updateRecByRst ()
{
	local RECDS=$1
	local REC=$2	
	
	case $3 in
		$TEST_RETVAL_PASS) STAT="PASS" ;; 
		$TEST_RETVAL_FAIL) STAT="FAIL" ;;
		$TEST_RETVAL_SKIP) STAT="SKIP" ;;
		$TEST_RETVAL_MANUAL) STAT="MANUAL" ;;
		*) STAT="UNTESTED" ;;
	esac

	eval "$RECDS.updateRecord $REC $STAT"
}

addTest ()
{
	local tests=$1
	local tst=$2
	
	added=`echo $tests | sed -n "/$tst/p"`
	
	[ -z "$added" ] && { tests="$tests $tst"; }
	
	echo -e $tests
}

addToTests ()
{
	local tests="$1"
	local toadd="$2"
	
	for tst in $toadd
	do
		tests=`addTest "$tests" "$tst"`
	done
	
	echo -e "$tests"
}

delTest ()
{
	local tests="$1"
	local tst=$2
	
	tests=`echo $tests | sed -e "s/$tst//"`

	echo -e "$tests"
}

delFromTests ()
{
	local tests=$1
	local tomv="$2"
	
	for tst in $tomv
	do
		tests=`delTest "$tests" "$tst"`
	done
	
	echo -e "$tests"
}

testsToContinue ()
{
	local tests=$1
	
	for tst in $tests; do
		local stat="$tst"_INPROG
		local foundRec=`pure.findRecord "$tst"`
		if [ ! -z "$foundRec" ]; then
			local foundStat=`pure.findRecord "$stat"`
			if [ ! -z "$foundStat" ]; then
				pure.removeRecord $tst
			else
				tests=`echo $tests | sed -e "s/$tst//"`
			fi
		fi
	done
	
	echo -e $tests
}

replaceSepByTok ()
{
	local torepl="$1"
	local sep=$2
	local tok=$3
	
	local ret=`echo $torepl | sed -e "s/$sep/$tok/g"`
	
	echo -e $ret
}

lowPriOptHandler ()
{
	local opts=$1
	
	new RECORDS pure "pure.recds"

	local en=`optEnabled "a" "$opts"`	
	[ -z "$en" ] || { TEST=$TEST; }	

	en=`optEnabled "q" "$opts"`	
	[ -z "$en" ] || { TEST=$TEST; QUIET_FLAG=1; }	

	en=`optEnabled "f" "$opts"`
	[ -z "$en" ] || { 
		TESTS_INFILE=`replaceSepByTok "$TESTS_INFILE" "," " "`
		TEST=`addToTests " " "$TESTS_INFILE"`; 
	}
	
	en=`optEnabled "s" "$opts"`
	[ -z "$en" ] || {
		TESTS_SELECTED=`replaceSepByTok "$TESTS_SELECTED" "," " "`
		TEST=`addToTests " " "$TESTS_SELECTED"`; 
# 		echo -e $TEST; 
	}

        en=`optEnabled "x" "$opts"`
        [ -z "$en" ] || {
                TEST_SUBCASE=`replaceSepByTok "$TEST_SUBCASE" ":" " "`
                TEST_SUBCASE=`addToTests " " "$TEST_SUBCASE"`;
                TEST=`echo $TEST_SUBCASE |awk '{print $1}'`;
                SUBCASE=`echo $TEST_SUBCASE |awk '{print $2}'`;
	}
	
	en=`optEnabled "v" "$opts"`
	[ -z "$en" ] || { 
		TESTS_TOEXCLUDE=`replaceSepByTok "$TESTS_TOEXCLUDE" "," " "`
		TEST=`delFromTests "$TEST" "$TESTS_TOEXCLUDE"`;
# 		echo -e $TEST;
	}
		
	en=`optEnabled "c" "$opts"`
	if [ -z "$en" ]; then
		pure.refreshRecords
	else
		TEST=`testsToContinue "$TEST"`
# 		echo -e $TEST
	fi
}

doReport ()
{
# Need fix later.
	echo -e "doReport."
}

printAllTests ()
{
	echo -e $TEST
}

collectAllTestsLogs ()
{
	echo -e $TEST
	local DATE="`date '+%Y-%m-%d-%H:%M:%S'`"
	local LOGNAME=$DATE-log
	local PURERESULT=$DATE.pure.recds
	mkdir -p /opt/pure/logs/$LOGNAME
	local RET=$?
	if [ $RET -ne 0 ]; then
		echo "Need to check the RTC"; 
		exit 0;
	fi
	if [ X"`ls /opt/pure/logs/log`" != X ];then
		echo "The log link has exsited, and would delet it!"
		rm -f /opt/pure/logs/log
	fi
	ln -sf /opt/pure/logs/$LOGNAME /opt/pure/logs/log
	if [ -f /opt/pure/pure.recds ];then
		cp /opt/pure/pure.recds /opt/pure/logs/$LOGNAME/$PURERESULT
		ln -sf /opt/pure/logs/$LOGNAME/$PURERESULT /opt/pure/logs/pure.recds
	else
		echo "Warning: there was no pure.recds file !!"
	fi
	for i in $TEST;
	do
		if [ -f /opt/pure/testcases/$i/$i.log ];then	
			echo "/opt/pure/testcases/$i/$i.log";
			mkdir -p /opt/pure/logs/$LOGNAME/$i ;
			cp /opt/pure/testcases/$i/$i.log /opt/pure/logs/$LOGNAME/$i;
		else
			echo "Warning: there was no /opt/pure/testcases/$i/$i.log !!";
		fi
	done
}

deletAllTestsLogs ()
{
	echo -e $TEST
	for i in $TEST;
	do
		if [ -f /opt/pure/testcases/$i/$i.log ];then	
			echo "rm -f /opt/pure/testcases/$i/$i.log";
			rm -f /opt/pure/testcases/$i/$i.log ;
		else
			echo "Warning: there was no /opt/pure/testcases/$i/$i.log !!";
		fi
	done
}

highPriOptHandler ()
{
	local opts=$1
	
	local en=`optEnabled "h" "$opts"`
	[ -z "$en" ] || { printUsage; exit 0; }	
	
	en=`optEnabled "l" "$opts"`
	[ -z "$en" ] || { collectAllTestsLogs; exit 0; }
		
	en=`optEnabled "p" "$opts"`
	[ -z "$en" ] || { printAllTests; exit 0; }
		
	en=`optEnabled "t" "$opts"`
	[ -z "$en" ] || { doReport; exit 0; }
	
	en=`optEnabled "D" "$opts"`
	[ -z "$en" ] || { collectAllTestsLogs; deletAllTestsLogs; exit 0; }
		
	echo -e "Bad high priority option in : $opts"
	exit
}

intelXeonCoreTestSet ()
{
	CPU_ID="`grep "microcode:" /var/log/kern.log | grep CPU | awk '{print $8}' | cut -d= -f2 | sed 's/,//g' | uniq`"
	case $CPU_ID in
	'0x306a5')
		BOARD_NAME=Sabino_Canyon ;;
	'0x206a6')	
		BOARD_NAME=Stargo ;;
	'0x206d5')
		BOARD_NAME=Canoe_Pass ;;
	'0x206a7')
		BOARD_NAME=EVOC_EC7-1817LNAR ;;
	'0x206a5')
		BOARD_NAME=Emerald_Lake ;;
	'0x20655')
		BOARD_NAME=MATXM-CORE-411-B ;;
	'0x20652')
		BOARD_NAME=Red_Fort ;;
	'0x206c2')
		BOARD_NAME=Greencity ;;
	'0x106a5')
		BOARD_NAME=Hanlan_Creek ;;
	'0x106e2')
		BOARD_NAME=Osage ;;
	*)
		BOARD_NAME=Default ;;
	esac
	BLACK_TESTS="`grep $BOARD_NAME $TOP_DIR/blacklist.conf | awk -F: '{print $2}'`"
	if [ ! -z "$BLACK_TESTS" ]; then
		TEST=`delFromTests "$TEST" "$BLACK_TESTS"`
	fi
}

# Main drive entry to get case list to test.
repackTestSet ()
{
	if [ -z "$HIGHPRI_OPTS" ]; then
		lowPriOptHandler "$LOWPRI_OPTS"
	else
		highPriOptHandler $HIGHPRI_OPTS
	fi
	BSPNAME="`uname -n`"
	case $BSPNAME in
	'intel-xeon-core')
		intelXeonCoreTestSet ;;
	esac
}
