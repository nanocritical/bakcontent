#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

for i in $(seq -w 8192); do
  echo 0 > f$i
done

bakcontent register

bakcontent store add localstore localstore
bakcontent store sync localstore

[[ "1" == $(count_store_files localstore) ]]

bakcontent snapshot
bakcontent store sync localstore
bakcontent store sync localstore

for i in $(seq -w 8192); do
  echo $i > f$i
done

bakcontent store sync localstore

[[ "8193" == $(count_store_files localstore) ]]

bakcontent snapshot
bakcontent store sync localstore

[[ "8193" == $(count_store_files localstore) ]]

bakcontent store add localstore2 localstore2

[[ "0" == $(count_store_files localstore2) ]]
[[ "0" == $(count_store_files .bakcontent/default) ]]

bakcontent store sync --all

[[ "8193" == $(count_store_files localstore) ]]
[[ "8192" == $(count_store_files localstore2) ]]
[[ "8192" == $(count_store_files .bakcontent/default) ]]

check_store_integrity .bakcontent/default
check_store_integrity localstore
check_store_integrity localstore2

teardown
