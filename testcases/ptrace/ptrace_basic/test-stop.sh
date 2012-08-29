#!/bin/sh
./dummy &
dummy_pid=`echo $!`

if test X"$dummy_pid" = "X"; then
	dummy_pid=`ps  | grep dummy |  awk '$NF ~ /^dummy/ {print $1}'`
fi

echo "dummy_pid: $dummy_pid"
sleep 10 
echo "run stop test, ./stop $dummy_pid "
./stop $dummy_pid
sleep 60
