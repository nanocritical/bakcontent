#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

for i in $(seq -w 8192); do
  echo 0 > f$i
done

bakcontent register

bakcontent store add localstore localstore
bakcontent store sync localstore
[[ "1" == $(find localstore -type f |grep -v .nobakcontent |wc -l) ]]

bakcontent snapshot
bakcontent store sync localstore
bakcontent store sync localstore

for i in $(seq -w 8192); do
  echo $i > f$i
done

bakcontent store sync localstore

[[ "8193" == $(find localstore -type f |grep -v .nobakcontent |wc -l) ]]

bakcontent snapshot
bakcontent store sync localstore

[[ "8193" == $(find localstore -type f |grep -v .nobakcontent |wc -l) ]]

bakcontent store add localstore2 localstore2

[[ "0" == $(find localstore2 -type f |grep -v .nobakcontent |wc -l) ]]
[[ "0" == $(find .bakcontent/default -type f |grep -v .nobakcontent |wc -l) ]]

bakcontent store sync --all

[[ "8193" == $(find localstore -type f |grep -v .nobakcontent |wc -l) ]]
[[ "8192" == $(find localstore2 -type f |grep -v .nobakcontent |wc -l) ]]
[[ "8192" == $(find .bakcontent/default -type f |grep -v .nobakcontent |wc -l) ]]

teardown
