set -e

export PATH=$PATH:$PWD/..

troot=$(dirname $0)
t=$(basename $0)

mkdir -p tmp_$t
cd tmp_$t

function teardown() {
  cd ..
  rm -rf tmp_$t
}
