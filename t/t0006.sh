#!/usr/bin/env bash

# Test separate bakcontent and stores

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

mkdir -p d
cp a b c d

mkdir -p e
cp a b c e

mkdir -p bk/.bakcontent
pushd bk > /dev/null
bakcontent register --bakcontent .bakcontent --root ..
popd > /dev/null

mkdir tangent
pushd tangent > /dev/null
bakcontent snapshot --bakcontent ../bk/.bakcontent
popd > /dev/null

bakcontent snapshot --bakcontent bk/.bakcontent

mkdir A
bakcontent store add A A --bakcontent bk/.bakcontent

pushd A > /dev/null
bakcontent store sync A --bakcontent ../bk/.bakcontent
popd > /dev/null

count=$(count_store_files A)
[[ "$count" == "3" ]]

mkdir bk/B
pushd bk/B > /dev/null
bakcontent store add B . --bakcontent ../../bk/.bakcontent
popd > /dev/null

pushd bk > /dev/null
bakcontent store sync B
popd > /dev/null

[[ "$count" == $(count_store_files bk/B) ]]

bakcontent store sync --bakcontent bk/.bakcontent
[[ "$count" == $(count_store_files A) ]]
[[ "$count" == $(count_store_files bk/B) ]]
[[ "$count" == $(count_store_files bk/.bakcontent/default) ]]

check_store_integrity A
check_store_integrity bk/B
check_store_integrity bk/B

teardown
