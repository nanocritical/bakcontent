
#!/usr/bin/env bash

# Test separate bakcontent and stores

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c

bakcontent register
bakcontent snapshot

test -f .bakcontent/history/a
a0=$(cat .bakcontent/history/a)

bakcontent snapshot
a1=$(cat .bakcontent/history/a)
test "$a0" == "$a1"

touch a
bakcontent snapshot
a2=$(cat .bakcontent/history/a)
test "$a0" != "$a2"

chmod +x a
bakcontent snapshot
a3=$(cat .bakcontent/history/a)
test "$a2" != "$a3"
test "$a0" != "$a3"

teardown
