#!/usr/bin/env bash

cd $(dirname $0)
. setup.sh 

echo 1 > a
echo 2 > b
echo 3 > c
ln -s a la
ln -s la lla
touch empty
mkdir -p d
cp a b c d

bakcontent register
[[ "1" == $(bakcontent store ls |wc -l) ]]
bakcontent snapshot

test -f .bakcontent/history/la
test -f .bakcontent/history/lla
test -f .bakcontent/history/d/a

cmp <(head -1 .bakcontent/history/la) \
  <(echo 1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75)
cmp <(head -1 .bakcontent/history/lla) \
  <(echo c4db6d08986ac0868f1285342944fb756ac6148b4452b77cf34e18dc2f914072d86705108eeb802b37b77eb6fdf2d28071dff3738ed576091220b09ab9a38168)
cmp <(head -1 .bakcontent/history/empty) \
  <(echo cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e)

mkdir -p e
cp a b c e
touch e/.nobakcontent

bakcontent snapshot

test ! -f .bakcontent/history/e/a

rm e/.nobakcontent

bakcontent snapshot

test -f .bakcontent/history/e/a

bakcontent unregister

touch e/.nobakcontent

bakcontent snapshot

test ! -f .bakcontent/history/e/a
test -f .bakcontent/history/la
test -f .bakcontent/history/lla
test -f .bakcontent/history/d/a

bakcontent store sync

test -f .bakcontent/default/data/1f4/1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75
test -f .bakcontent/default/data/cf8/cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e

check_store_integrity .bakcontent/default

teardown
