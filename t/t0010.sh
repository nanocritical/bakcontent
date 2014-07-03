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
diff -u <(echo -e "+ d\nM c\n- a") <(bakcontent diff)

bakcontent snapshot
diff -u <(cat /dev/null) <(bakcontent diff)

mkdir e
echo 6 > e/f
echo 7 > a
diff -u <(echo -e "+ a\n+ e/f") <(bakcontent diff)
diff -u <(echo -e "+ e/f") <(bakcontent diff e)

bakcontent snapshot
diff -u <(cat /dev/null) <(bakcontent diff)

rm -r e
diff -u <(echo -e "- e/f") <(bakcontent diff)
bakcontent snapshot
diff -u <(cat /dev/null) <(bakcontent diff)

teardown
