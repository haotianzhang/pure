#! /bin/bash

source lib/testlib.sh

TOP_DIR=`pwd`

# Main entry for testing.
doTest ()
{
	local TEST="$1"
	local SUBCASE="$2"
	for TESTRUN in $TEST; do
		cd $TOP_DIR
		new RUN_TEST test_run "$TESTRUN"
		print_info_begin `test_run.showTYPE` `test_run.showTIMEOUT`
		./bin/operation_progress.sh $$ `test_run.showTIMEOUT` $TESTRUN $QUIET_FLAG &
		eval progress_id=`echo $!`
		pure.addRecord $TESTRUN "INPROG"		
		test_run.startTEST $SUBCASE
		pstree -p | grep -q $progress_id && kill -9 $progress_id
		test_run.checkRST
		updateRecByRst "pure" $TESTRUN `test_run.getTESTRST`
		print_info_end
	done	
}

main ()
{
	printTestCaseName
	doTest "$TEST" "$SUBCASE"
}

setup_test
optionParse $*
repackTestSet
main 2>stderr
