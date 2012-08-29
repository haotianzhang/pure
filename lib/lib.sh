#!/bin/bash

source lib/function.sh

function pre_environment_check
{
        [ -e ~/config ] && rm ~/config
        [ -r /proc/config.gz -o -r /boot/config-$KERNEL_VERSION ] || {
                echo "FATAL: missing file /proc/config.gz"
                exit $TEST_RETVAL_FAIL
        }
        [ -d ~ ] || {
                echo "FATAL: missing home directory"
                exit $TEST_RETVAL_FAIL
        }
        which gunzip >& /dev/null || {
                echo "FATAL: gunzip not found"
                exit $TEST_RETVAL_FAIL
        }
}


#ARCH=$(uname -m)
#KERNEL_VERSION=$(head -n 1 /proc/version | sed 's/.*WR\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
#KERNEL_TYPE=$(awk '{print $3}' /proc/version | cut -d "-" -f2 | cut -d "_" -f2 )
#VERSION=`cat /etc/issue | grep "Wind" | awk '{print $NF}'`
VERSION=$(tail -n 1 test_cases.matrix)
if [ x"$VERSION" = x"" ]; then
	VERSION=`cat /etc/issue`
fi
KERNEL_VERSION=`uname -a| cut -d' ' -f 3`

function generate_kernel_cfg
{
        pre_environment_check
        [ -r /proc/config.gz ] && cp /proc/config.gz ~/ && gunzip ~/config.gz
        [ -r /boot/config-$KERNEL_VERSION ] && cp /boot/config-$KERNEL_VERSION ~/config
}

function genrate_test_matrix
{
        TESTDIR=`ls testcases/*/runtest.sh | sed "s/\/runtest.sh//g"`
        TEST=`ls testcases/*/runtest.sh | sed "s/\/runtest.sh//g" | sed "s/testcases\///g"`
}

function setup_test
{
        generate_kernel_cfg
        genrate_test_matrix
        #echo $TESTDIR
}

function print_info
{
        echo -e "\t~~~~~~~~~~~~~~~~~~ Pure Report ~~~~~~~~~~~~~~~~~~~~~~"
        echo -e "\tLINUX distro: $VERSION"
        echo -e "\tKernel Version: $KERNEL_VERSION" 
        echo -e "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

}

function print_info_begin
{
	let "duration=$2 / 10" 
        echo -e "\tStart TESTING"
        echo -e "\t$1: [$TESTRUN]"
        echo -e "\tTesting Start at `date`"
        echo -e "\tTesting duration: $duration s"
}

function print_info_end
{

        echo -e "\tFinished TESTING"
        echo -e "\t=========================================="
        echo
}

