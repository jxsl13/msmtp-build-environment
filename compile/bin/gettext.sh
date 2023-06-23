#!/bin/bash -e


# script path without .sh extension
SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]%.*})"
# source ../compile.sh relative to this file, not relative to the current working directory
COMPILE="$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../compile.sh")"
. "$COMPILE" --source-only
init "$SCRIPT_PATH"
mk_build_dir
cd_src_dir

files_before_build
# gettext 0.21, 0.22 will fail at test-fnmatch, so we use 0.20
# MUST keep --enable-shared otherwise the build process will fail (we don't want to fix the build process)
./configure --prefix=$PREFIX --enable-shared --enable-static --disable-libasprintf && \
make -j $CORES && \
make check && \
make install && \
RC=0 || RC=1
stop

diff_and_package_files
exit $RC

