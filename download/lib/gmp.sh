#!/bin/bash -e

# parameters
URL=https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz


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