#!/bin/bash
# a script to test clock_gettime function on gos
#
# Copyright (c) 2011 Wind River Systems, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##

source /opt/pure/lib/function.sh
TC_PATH=`dirname $0`
TC_SCRIPT=`basename $0`


[ -x $TC_PATH/clock_gettime ] || {
	echo "check the binary"
	exit $TEST_RETVAL_SKIP
}

$TC_PATH/clock_gettime
ret=$?

if [ $ret = 0 ]; then
	echo PASS to test clock_gettime
	exit $TEST_RETVAL_PASS
else
	echo FAIL to test clock_gettime
	exit $TEST_RETVAL_FAIL
fi

