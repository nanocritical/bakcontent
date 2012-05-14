#!/bin/bash

cd $(dirname $0)
test=$(basename $0)

mkdir -p tmp_$test
cd tmp_$test

echo 1 > a
echo 2 > b
echo 3 > c
mkdir -p d
cp a b c d

mkdir -p e
cp a b c e
touch e/.bakcontent_donotbackup

../../bakcontent snapshot .
touch f
../../bakcontent store .
../../bakcontent snapshot .
../../bakcontent store .

cd ..
rm -rf tmp_$test
