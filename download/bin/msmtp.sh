#!/bin/bash -e

# msmtp is a mailing client that allows to authenticate with various AUTH mechanisms which ar enot supported in any Perl native library.
# INFO: We use an older version which requires gettext 0.18 which is the only gettext version available on Debian 7 Wheezy (really old).
# In case out GNU does not require Debian 7 (glibc.2.13) anymore but a newer one which support gettext 0.20, 0.21, etc,
# we might update this version in oder to have more features available.

# WARNING: Any version above 1.8.14 requires gettext 0.19, 0.20 or even 0.21 which is NOT available on Debian 7 Wheezy (our build environment for glibc2.13 builds)

# It is encouraged to use OpenSSL but use GnuTLS instead: https://marlam.de/msmtp/news/openssl-discouraged/
# but for our needs we will still use OpenSSL.
# https://marlam.de/msmtp/download/
# https://github.com/marlam/msmtp-mirror/tags
# parameters
URL=https://github.com/marlam/msmtp-mirror/archive/refs/tags/msmtp-1.8.23.tar.gz


# stays the same, e.g. zip, gmp, openssl, perl
EXTRACTION_DIR="$(basename ${0%.*})"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# bin, lib, etc.
BUILD_TYPE="$(basename $SCRIPT_DIR)"

RELATIVE_TARGET_DIR="$SCRIPT_DIR/../../src/$BUILD_TYPE"
ABSOLUTE_TARGET_DIR="$(realpath $RELATIVE_TARGET_DIR)"
ABSOLUTE_EXTRACTION_DIR="$ABSOLUTE_TARGET_DIR/$EXTRACTION_DIR"

echo "Deleting old dir: $ABSOLUTE_EXTRACTION_DIR"
rm -rf "$ABSOLUTE_EXTRACTION_DIR"


$SCRIPT_DIR/.././download.sh "$BUILD_TYPE" "$EXTRACTION_DIR" "$URL"