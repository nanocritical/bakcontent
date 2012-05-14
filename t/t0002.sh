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

touch .bakcontent_donotbackup

if ../../bakcontent backup . &> /dev/null; then
  echo "Command should have failed"
  exit 1
fi

cd ..
rm -rf tmp_$test
