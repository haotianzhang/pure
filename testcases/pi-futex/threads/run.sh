#!/bin/bash

source /opt/pure/lib/function.sh

CURRENT_DIR=$(pwd)
TEST_DIRS="pi_test"

for test_dir in $TEST_DIRS; do

echo ""
echo "Run $test_dir tests"
echo "=============================="
echo ""
        cd $CURRENT_DIR/$test_dir;
	./run.sh
	if [ $? -eq 0 ]; then
		exit $TEST_RETVAL_PASS;
	else
		exit $TEST_RETVAL_FAIL;
	fi
done

