#!/bin/bash -e

# INFO: Version 1.0.4 does not build correctly, as the generated build instructions seem to not be correct
# THat's why we use gss-1.0.3
# script path without .sh extension
SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]%.*})"
# source ../compile.sh relative to this file, not relative to the current working directory
COMPILE="$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../compile.sh")"
. "$COMPILE" --source-only
init "$SCRIPT_PATH"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
export CFLAGS="-std=c99 -std=gnu99 $CFLAGS"
export CPPFLAGS="$CPPFLAGS"
export LDFLAGS="$LDFLAGS"

mk_build_dir
cd_src_dir

files_before_build

./configure --prefix=$PREFIX --enable-static --disable-shared && \
make -j $CORES && \
make check && \
make install && \
RC=0 || RC=1
stop

diff_and_package_files
exit $RC

