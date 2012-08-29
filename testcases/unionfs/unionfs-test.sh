#!/bin/bash

dir=`dirname $0`

unionfs_dir="$dir/../unionfs"

cd $unionfs_dir
./runtest.sh >$WRST_RAWLOG 2>&1 ; exit $?
