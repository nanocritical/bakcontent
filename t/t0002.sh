#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

for i in $(seq -w 8192); do
  echo 0 > f$i
done

bakcontent register

bakcontent store add localstore localstore
bakcontent store sync localstore
[[ "1" == $(find localstore -type f |grep -v .bakcontent |wc -l) ]]

bakcontent snapshot
bakcontent store sync localstore
bakcontent store sync localstore

for i in $(seq -w 8192); do
  echo $i > f$i
done

bakcontent store sync localstore

find localstore -type f |grep -v .bakcontent |wc -l
[[ "8193" == $(find localstore -type f |grep -v .bakcontent |wc -l) ]]

bakcontent snapshot
bakcontent store sync localstore

[[ "8193" == $(find localstore -type f |grep -v .bakcontent |wc -l) ]]

teardown
