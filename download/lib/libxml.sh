#!/bin/bash -e

# parameters

# do not change the xml-version as the perl xml module might fail to compile
# https://www.w3.org/XML/Test/
URL=http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz
TEST_URL=https://www.w3.org/XML/Test/xmlts20130923.tar.gz


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
$SCRIPT_DIR/.././download.sh "$BUILD_TYPE" "$EXTRACTION_DIR/xmlconf" "$TEST_URL"