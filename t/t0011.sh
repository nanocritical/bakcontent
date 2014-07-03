#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

bakcontent register
bakcontent archive

echo 4 > c
echo 5 > d
rm a
diff -u <(echo -e "+ d\nM c\n- a") <(bakcontent diff)

diff -u <(echo -e "M c") <(bakcontent checkout)
diff -u <(echo -e "+ d\nM c") <(bakcontent diff)
test -f a

bakcontent archive

rm a
diff -u <(cat /dev/null) <(bakcontent checkout a)
test -f a

rm a
diff -u <(echo -e "Unknown path 'aaaa'") <(bakcontent checkout aaaa 2>&1)

rm c
bakcontent checkout
diff -u <(cat /dev/null) <(bakcontent diff)
test -f a
test -f c

mkdir e
echo 6 > e/f
bakcontent snapshot

rm -r e
diff -u <(echo -e "No data file f3d08a4bfef201adbe711e8805f96ff13909719107dcac81f4fc9185040d59d8d573344a0707e697f8b4f0212e0d79f3bdd6b86688dd8c54019b9d93c937f3ca in 'default' for e/f") <(bakcontent checkout 2>&1)

mkdir e
echo 6 > e/f
bakcontent store

rm -r e
bakcontent checkout
test -f e/f

teardown
