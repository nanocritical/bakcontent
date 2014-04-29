#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

seq $((10*1024*1024)) > a

bakcontent register

# The second snapshot call should be significantly faster than 1 and 3
( time bakcontent snapshot

time bakcontent snapshot

touch a
time bakcontent snapshot ) &> /dev/null

teardown
