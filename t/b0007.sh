#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 


seq -w 500000 > mid
seq -w 1000000 > big

for i in $(seq 200); do
  cp -p mid f$((2*i))
  cp -p big f$((2*i+1))
done

du -cksh .

bakcontent register

echo The first time should ideally only be a bit longer than the second

time bakcontent archive

time find -type f |xargs -P4 -n16 sha512sum > /dev/null

teardown
