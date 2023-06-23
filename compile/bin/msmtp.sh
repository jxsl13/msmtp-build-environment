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
export LDFLAGS="$LDFLAGS"
# -lrt -ldl -lidn -lntlm -lgss -lgsasl
cd_src_dir
files_before_build

# undefined references:
#   __res_query ns_initparse ns_parserr __dn_expand   -> -lresolv
#   clock_gettime                                     -> -lrt
#   dlfcn_load dlopen dlerror dlclose dlfcn_unload    -> -ldl


autoreconf -i -I "$PREFIX/include" && \
./configure --prefix=$PREFIX --without-msmtpd --disable-nls --with-tls=openssl --with-libidn --with-libgsasl --with-libsecret=no &&
make V=1 -j $CORES LIBS="-lgsasl -lgss -lidn -lntlm -ldl -lrt -lresolv" &&
make install &&
RC=0 || RC=1

diff_and_package_files

exit $RC