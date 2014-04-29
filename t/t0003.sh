#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

mkdir -p d
cp a b c d

mkdir -p e
cp a b c e

bakcontent register
bakcontent snapshot

! bakcontent store add clash .bakcontent/default
bakcontent unregister

bakcontent register
bakcontent snapshot

bakcontent archive
count=$(count_store_files .bakcontent/default)

bakcontent store
[[ "$count" == $(count_store_files .bakcontent/default) ]]

teardown
