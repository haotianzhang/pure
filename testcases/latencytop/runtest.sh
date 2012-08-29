#!/bin/bash

source /opt/pure/lib/function.sh

RUNTIME=125   # seconds
FIFO_INPUT="/tmp/.latencytop-$$"
mkfifo -m 600 $FIFO_INPUT

function FailExit()
{
    echo "########################################################"
    echo "# Fail: Test LatencyTop "
    echo "########################################################"
    rm -f $FIFO_INPUT
    exit $TEST_RETVAL_SKIP
}

## Clean
pkill latencytop

echo "########################################################"
echo "# Start to test LatencyTop "
echo "########################################################"

which latencytop || FailExit

#bash -c "sleep $RUNTIME; echo q >$FIFO_INPUT" &
( sleep $RUNTIME; echo q >$FIFO_INPUT ) &
echo "Run latencytop for $RUNTIME seconds ..."

time latencytop <$FIFO_INPUT >/dev/null

## Check output
#

echo "########################################################"
echo "# Pass: Test LatencyTop "
echo "########################################################"
rm -f $FIFO_INPUT
exit $TEST_RETVAL_PASS

