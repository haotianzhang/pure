#!/bin/bash

echo -ne   "\n"
echo "****PI testcase will run!****"

fno=1
while((fno<=6))
do
  echo -ne   "\n"
  echo     "************************"
  echo     "*****pitest-${fno} start*****"
  echo -ne "************************\n"

  ./pitest-${fno}
#  if ["$?" -eq 0]
  echo "*****pitest-${fno} end*****"
  echo -n
  let fno=$fno+1
done

echo -ne   "\n"
echo "****PI testcase end****"


