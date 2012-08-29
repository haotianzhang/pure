#!/bin/bash

source /opt/pure/lib/function.sh

function writefile()
{
    f=$1
    shift
    echo $* >$f
}

function mkbranch()
{
BRANCH=branch$1
FILE=file$1
DIR=dir$1
COMDIR=$2
COMFILE=$3
COMFILEA=$4
COMFILEB=$5

rm -rf $BRANCH
mkdir $BRANCH
cd $BRANCH && \
mkdir $DIR $COMDIR && \
touch $FILE $DIR/$FILE $COMDIR/$FILE $COMDIR/$COMFILE && \
echo "$BRANCH commonfile" >$COMDIR/$COMFILE && \
cp $COMDIR/$COMFILE $COMFILEA && \
cp $COMDIR/$COMFILE $COMFILEB || \
{ cd ..;return $TEST_RETVAL_FAIL; }
cd ..
}

# test unionfs
function unionfsTest()
{
WORKDIR=$(pwd)
mkdir mnt

mkbranch 1 comdir comfile123 comfile12 comfile13 && \
mkbranch 2 comdir comfile123 comfile12 comfile23 && \
mkbranch 3 comdir comfile123 comfile23 comfile13 || \
    { echo ERROR: Cannot build test files or dirs,exit;return 1; }

i=1
while read cmd args;do
[[ $cmd =~ ^#|^$ ]] && continue
echo "($i)> $cmd $args"
if [[ $cmd == "!" ]];then
    $args && { cd $WORKDIR;umount mnt;echo "ERROR:$i: expect FAIL";return 1;}
else
    $cmd $args || { cd $WORKDIR;umount mnt;echo "ERROR:$i: expect PASS";return 2;}
fi
((i++))
done <<-EOF
#Test commands,only Simple Commands can be put here
    
#mount unionfs
mount -t unionfs -o dirs=branch1:branch2:branch3 none mnt

cd mnt
ls comfile12 comfile23 comfile13
grep branch1 comfile12
grep branch2 comfile23
grep branch1 comdir/comfile123
ls comdir/file1 comdir/file3 comdir/file2
ls file1 file2 file3
ls dir1/file1 dir2/file2 dir3/file3
cd ..

#To downgrade a union from read-write to read-only
mount -t unionfs -o remount,ro none mnt

cd mnt
! writefile file1 "Impossible"
! writefile comdir/comfile123 "Impossible"
! mv dir2 dir22
! mv comdir comdir123
cd ..

#To upgrade a union from read-only to read-write
mount -t unionfs -o remount,rw none mnt

cd mnt
writefile file2 "Fine"
writefile comdir/file3 "Fine"
cd ..

#To delete a branch
mount -t unionfs -o remount,del=branch2 none mnt

cd mnt
! ls file2
! ls dir2/file2
! ls comdir/file2
grep branch3 comfile23
cd ..

#To insert (add) a branch /foo before /bar
mount -t unionfs -o remount,add=branch3:branch2 none mnt

cd mnt
grep branch1 comfile12
grep branch2 comfile23
grep branch1 comdir/comfile123
ls comdir/file2 file2 dir2/file2
cd ..

#To delete a branch
mount -t unionfs -o remount,del=branch1,del=branch3 none mnt

cd mnt
grep branch2 comfile12
grep branch2 comdir/comfile123
! ls dir1
! ls comdir/file3
cd ..

#To append a branch to the very end (new lowest-priority branch) in read-only mode
mount -t unionfs -o remount,add=:branch3=ro none mnt

cd mnt
grep branch2 comfile23
ls file3 dir3/file3 comdir/file3
writefile file3 "Suspected"
! grep Suspected ../branch3/file3
cd ..

#To insert (add) a branch /foo (in "rw" mode) at the very beginning
mount -t unionfs -o remount,add=branch1 none mnt

cd mnt
grep branch1 comfile12
grep branch1 comdir/comfile123
ls file1 dir1 comdir/file1
cd ..

#Finally, to change the mode of one existing branch
mount -t unionfs -o remount,mode=branch2=rw,mode=branch3=rw none mnt

cd mnt
writefile dir3/file3 "Fine"
grep Fine ../branch3/dir3/file3
writefile comdir/file2 "Fine nice"
grep Fine ../branch2/comdir/file2
cd ..

#Update objects of lower branches
touch branch2/f2
writefile branch2/f2 "branch2"
mkdir branch3/d3
mv branch1/file1 branch1/file11
mv branch2/file2 branch2/file22
mv branch3/comfile13 branch3/comfile3
rm branch2/dir2/file2
mount -t unionfs -o remount,incgen none mnt

cd mnt
grep branch2 f2
ls d3 file11 file22 comfile13 comfile3
! ls dir2/file2
cd ..

# touch
cd mnt
touch file
mkdir dir
touch dir1/f1
touch dir2/f2
ls ../branch1/file ../branch1/dir
ls ../branch1/dir1/f1 ../branch2/dir2/f2

# rm
rm comdir/comfile123
! ls comdir/comfile123
! ls ../branch1/comdir/comfile123
! ls ../branch2/comdir/comfile123
rm file3
! ls file3
! ls ../branch3/file3
rm -rf comdir
! ls comdir
! ls ../branch1/comdir
ls ../branch2/comdir ../branch3/comdir
! ls ../branch2/comdir/file2
! ls ../branch3/comdir/file3
rm -rf dir2
! ls dir2
! ls ../branch2/dir2
ls -l *
rm -r *
cd ..

umount mnt

# rebuild test files and dirs
mkbranch 1 comdir comfile123 comfile12 comfile13
mkbranch 2 comdir comfile123 comfile12 comfile23
mkbranch 3 comdir comfile123 comfile23 comfile13
mount -t unionfs -o dirs=branch1:branch2:branch3=ro none mnt

cd mnt
ls comfile12 comfile23 comfile13
ls comdir/file1 comdir/file3 comdir/file2
ls file1 file2 file3
ls dir1/file1 dir2/file2 dir3/file3

# rename
mv file1 file
ls file ../branch1/file
mv file2 file
ls file ../branch2/file
! ls ../branch1/file
rm dir3/file3
! ls dir3/file3
ls ../branch3/dir3/file3

rm comdir/comfile123
rm comdir/file1 comdir/file2 comdir/file3
rename comdir dir3 comdir
ls dir3
! ls comdir

rm dir1/file1 dir2/file2
mv dir2 dir
ls ../branch2/dir
rename dir1 dir dir1
ls ../branch2/dir
ls ../branch1/dir
rename dir dir3 dir
ls dir3 ../branch1/dir3
ls -a *
rm -r *
cd ..

 umount mnt

EOF
}

# main

rm -rf /root/unionfs
mkdir -p /root/unionfs
cd /root/unionfs

unionfsTest
RET=$?

cd /root
rm -rf /root/unionfs

if [ $RET = 0 ];then
    echo unionfs test PASS
    exit $TEST_RETVAL_PASS
else
    echo unionfs test FAIL
    exit $TEST_RETVAL_FAIL
fi
