#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

mkdir .bakcontent

bakcontent snapshot

# We turn a file into a directory.
rm c
mkdir c
touch c/cc

bakcontent snapshot

teardown
