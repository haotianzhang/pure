#!/bin/bash
source /opt/pure/lib/function.sh

./mutex_lock1 &
proj1_id=$! 
./mutex_lock2 &
proj2_id=$!

 
sleep 300
a=`vmstat |awk 'NR==3{print $14}'`
echo the system cpu stat is $a% 

kill -9 $proj1_id
if [ $? -ne 0 ];then
echo Can not kill the pid $proj1_id process.
exit $TEST_RETVAL_FAIL
fi

kill -9 $proj2_id
if [ $? -ne 0 ];then
echo Can not kill the pid $proj2_id process.
exit $TEST_RETVAL_FAIL
fi

if [ $a -ge 80 ]
then
exit $TEST_RETVAL_FAIL
else
exit $TEST_RETVAL_PASS
fi 

