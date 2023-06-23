#!/bin/bash -e


# script path without .sh extension
SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]%.*})"
# source ../compile.sh relative to this file, not relative to the current working directory
COMPILE="$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../compile.sh")"
. "$COMPILE" --source-only
init "$SCRIPT_PATH"

export LDFLAGS="$LDFLAGS"

mk_build_dir
cd_src_dir

files_before_build

# library specific compilation code
# https://github.com/openssl/openssl/blob/master/test/README.md#test-failures

./config --prefix=$PREFIX --openssldir=$PREFIX/openssl no-shared no-threads $LDFLAGS && \
make -j $CORES && \
make V=1 VFP=1 test && \
make install && \
RC=0 || RC=1
stop

diff_and_package_files
exit $RC
