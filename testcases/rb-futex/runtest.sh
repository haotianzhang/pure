#!/bin/bash

source /opt/pure/lib/function.sh

ERROR=0
display()
{
  echo -ne   "\n"
  echo     "*****************************"
  echo     "******$1 start******"
  echo -ne "*****************************\n"
}
checkreturn()
{
    if [ $1 -eq 0 ]; then
        echo 
        echo "******$2 pass******"
    else
	echo
	echo "******$2 fail******"
	ERROR=1;
    fi
    echo "*******$2 end*******"
}




#Main entry

echo -ne   "\n"
echo "****Robust testcase will run!****"

if test X"$1" != "X"; then
	cmdlist=$1
        display $1
        nptl/$1
        checkreturn $? $1

else
	cmdlist=(tst-robust tst-robustpi)
	for cmd in ${cmdlist[@]}; do
		fno=1
		while((fno<=8));do
			display ${cmd}${fno}
			nptl/${cmd}${fno}
			checkreturn $? ${cmd}${fno}
			fno=$(($fno + 1))
		done
	done
fi

echo -ne   "\n"
echo "****Robust testcase end****"

[ $ERROR -eq 1 ] && exit $TEST_RETVAL_FAIL;

echo 
echo "***Robust testcase PASS!****"

