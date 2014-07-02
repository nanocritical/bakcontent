#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

bakcontent register
bakcontent snapshot

echo 4 > c
echo 5 > d
rm a
cmp <(echo -e " + ./d\n-+ ./c\n-  ./a") <(bakcontent diff)

bakcontent snapshot

cmp <(cat /dev/null) <(bakcontent diff)

teardown
