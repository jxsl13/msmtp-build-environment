#!/bin/bash -e

# WARNING: do not use this file in any new GNU versions
# we do not know where on a target host the CA bundle or CA path might be located.
# Use the system wget.

# script path without .sh extension
SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]%.*})"
# source ../compile.sh relative to this file, not relative to the current working directory
COMPILE="$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../compile.sh")"
. "$COMPILE" --source-only
init "$SCRIPT_PATH"
mk_build_dir
cd_src_dir

files_before_build


./configure --prefix=$PREFIX --with-ssl=openssl --with-openssl --with-libssl-prefix=$PREFIX && \
make && \
make install && \
RC=0 || RC=1
stop

diff_and_package_files
exit $RC