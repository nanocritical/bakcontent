#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

# Not registered.
! bakcontent snapshot &> /dev/null

bakcontent register
bakcontent snapshot

# We turn a file into a directory.
rm c
mkdir c
touch c/cc

bakcontent snapshot
test -f .bakcontent/history/c/cc

# We remove a file.
rm a
bakcontent snapshot
test ! -f .bakcontent/history/a

# We remove a file making a directory empty.
rm c/cc
bakcontent snapshot
test ! -e .bakcontent/history/c

touch c/cc
bakcontent snapshot

# We remove a directory.
rm -r c
bakcontent snapshot
test ! -e .bakcontent/history/c

teardown
