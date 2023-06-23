#!/bin/bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "Starting downloads..."

# build tools gettext, autoconf & texinfo first
# followed by libraries
mkdir -p "$SCRIPT_DIR/src" &&
./download/bin/./gettext.sh &&
./download/bin/./autoconf.sh &&
./download/bin/./texinfo.sh &&
\
./download/lib/./zlib.sh &&
./download/lib/./gmp.sh &&
./download/lib/./expat.sh &&
./download/lib/./libxml.sh &&
./download/lib/./nettle.sh &&
./download/lib/./openssl.sh &&
\
./download/lib/./libidn.sh &&
./download/lib/./libidn2.sh &&
./download/lib/./libntlm.sh &&
./download/lib/./gss.sh &&
./download/lib/./libgsasl.sh &&
\
./download/bin/./curl.sh &&
./download/bin/./wget.sh &&
./download/bin/./msmtp.sh &&
RC=0 || RC=1

echo "Downloads finished with return code: $RC"
exit $RC


