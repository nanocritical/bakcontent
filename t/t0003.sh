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

rm a
mkdir a
touch a/aa

bakcontent snapshot
bakcontent unregister

bakcontent register
bakcontent store add store1 .bakcontent/content
bakcontent store add store2 .bakcontent

teardown
