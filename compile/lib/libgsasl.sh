#!/bin/bash -e


# script path without .sh extension
SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]%.*})"
# source ../compile.sh relative to this file, not relative to the current working directory
COMPILE="$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../compile.sh")"
. "$COMPILE" --source-only
init "$SCRIPT_PATH"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
export CFLAGS="$CFLAGS"
export CPPFLAGS="$CPPFLAGS"

# https://www.gnu.org/software/gsasl/
export CFLAGS="-std=c99 -std=gnu99 $CFLAGS"
export LDFLAGS="$LDFLAGS"

mk_build_dir
cd_src_dir
files_before_build

# -l:libXXX.a forces to use the static library
./configure --prefix=$PREFIX --enable-static --disable-shared && \
make -j $CORES LIBS="-l:libgss.a -l:libidn.a -l:libntlm.a" && \
make check && \
make install && \
RC=0 || RC=1
stop

diff_and_package_files
exit $RC

