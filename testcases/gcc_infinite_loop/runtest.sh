#!/bin/bash
#  Copyright 2012 Wind River Systems, Inc.
#
# The right to copy, distribute or otherwise make use of this software may be
# licensed only pursuant to the terms of an applicable Wind River license
# agreement. No license to Wind River intellectual property rights is granted
# herein. All rights not licensed by Wind River are reserved by Wind River.
# %changelog
# * Aug 1 CST 2012 Guojian.Zhou <guojian.zhou@windriver.com>
# 

source /opt/pure/lib/function.sh

./test

if [ $? -eq 0 ]; then
	echo "Gcc infinit loop Test: PASS!"
	exit $TEST_RETVAL_PASS
else
	echo "Gcc infinit loop Test: FAIL!"
	exit $TEST_RETVAL_FAIL
fi

