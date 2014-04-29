set -e

export PATH=$PATH:$PWD/..

troot=$(dirname $0)
t=$(basename $0)

mkdir tmp_$t || (echo run ./cleantests after a failure; exit 1)
cd tmp_$t

function teardown() {
  cd ..
  rm -rf tmp_$t
}

function count_store_files() {
  find $1 -type f |grep -v .nobakcontent |grep -v histories |wc -l
}
