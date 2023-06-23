#!/bin/bash

#./download.sh [bin|lib|module] EXTRACTION_DIR URL [SHA256_URL]

BUILD_TYPE="$1"
EXTRACTION_DIR="$2"
shift 2

URL="$1"
SHA256_URL="$2"

# directory of this current script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# target directory, e.g. src/bin, src/lib, etc.
RELATIVE_TARGET_DIR="$SCRIPT_DIR/../src/$BUILD_TYPE"
ABSOLUTE_TARGET_DIR="$(realpath $RELATIVE_TARGET_DIR)"
ABSOLUTE_EXTRACTION_DIR="$ABSOLUTE_TARGET_DIR/$EXTRACTION_DIR"

echo "Creating dir: $ABSOLUTE_TARGET_DIR"
mkdir -p "$ABSOLUTE_TARGET_DIR"

echo "URL                     = $URL"
echo "BUILD_TYPE              = $BUILD_TYPE"
echo "EXTRACTION_DIR          = $EXTRACTION_DIR"
echo "ABSOLUTE_EXTRACTION_DIR = $ABSOLUTE_EXTRACTION_DIR"

RC=0
FILENAME="$(curl -OSsJLw '%{filename_effective}' --insecure --create-dirs $URL)"
RC="$?"

if [ "$RC" -ne 0 ]; then
  if [ "$RC" -eq 139 ]; then
    echo "Error: curl died due to a segmentation fault."
  fi
  echo "Error($RC) Failed to download $URL"
  exit $RC
fi

ABSOLUTE_TARGET_PATH="$ABSOLUTE_TARGET_DIR/$FILENAME"
echo "Downloaded $URL -> $(pwd)/$FILENAME"

echo "Moving $(pwd)/$FILENAME -> $ABSOLUTE_TARGET_PATH"
mv -u "$FILENAME" "$ABSOLUTE_TARGET_PATH" && RC=0 || RC=1
if [ "$RC" -ne 0 ]; then
  echo "Error($RC) Failed to move file: $FILENAME"
  exit $RC
fi

if [ -n "$SHA256_URL" ]; then

  SHA256_FILENAME="$FILENAME.sha256"
  ABSOLUETE_TARGET_SHA256_PATH="$ABSOLUTE_TARGET_DIR/$SHA256_FILENAME"

  curl -OSsJL --insecure --create-dirs "$SHA256_URL" -o "$SHA256_FILENAME" && RC=0 || RC=1
  if [ "$RC" -ne 0 ]; then
    if [ "$RC" -eq 139 ]; then
      echo "Error: curl died due to a segmentation fault."
    fi
    echo "Error($RC) Failed to download $SHA256_URL"
    exit $RC
  fi
  echo "Downloaded $URL -> $(pwd)/$SHA256_FILENAME"
  echo "Moving $(pwd)/$SHA256_FILENAME -> $ABSOLUETE_TARGET_SHA256_PATH"
  mv -u "$SHA256_FILENAME" "$ABSOLUETE_TARGET_SHA256_PATH" && RC=0 || RC=1
  if [ "$RC" -ne 0 ]; then
    echo "Error($RC) Failed to move file: $SHA256_FILENAME"
    exit $RC
  fi

  echo "Checking $ABSOLUTE_TARGET_PATH with sum file $ABSOLUETE_TARGET_SHA256_PATH $(cat "$ABSOLUETE_TARGET_SHA256_PATH")"
  # https://unix.stackexchange.com/questions/139891/why-does-verifying-sha256-checksum-with-sha256sum-fail-on-debian-and-work-on-u
  # two spaces between sha256 checksum and file path
  echo "$(cat "$ABSOLUETE_TARGET_SHA256_PATH")  $ABSOLUTE_TARGET_PATH" | sha256sum --check --status && RC=0 || RC=42
  if [ "$RC" -ne 0 ]; then
    echo "Error($RC) sha256sum check failed"
    exit $RC
  fi
fi

echo "Creating new directory: $ABSOLUTE_EXTRACTION_DIR"
mkdir -p "$ABSOLUTE_EXTRACTION_DIR" && RC=0 || RC=1
if [ "$RC" -ne 0 ]; then
  echo "Error($RC) Failed to create directories"
  exit $RC
fi

# extract
echo "Extracting $ABSOLUTE_TARGET_PATH -> $ABSOLUTE_EXTRACTION_DIR"
if [[ $ABSOLUTE_TARGET_PATH == *.tar.gz ]]; then # * is used for pattern matching
  echo "tar -zxf '$ABSOLUTE_TARGET_PATH' --directory '$ABSOLUTE_EXTRACTION_DIR' --strip 1"
  tar -zxf "$ABSOLUTE_TARGET_PATH" --directory "$ABSOLUTE_EXTRACTION_DIR" --strip 1 && RC=0 || RC=1
elif [[ $ABSOLUTE_TARGET_PATH == *.tgz ]]; then
  echo "tar -zxf '$ABSOLUTE_TARGET_PATH' --directory '$ABSOLUTE_EXTRACTION_DIR' --strip 1"
  tar -zxf "$ABSOLUTE_TARGET_PATH" --directory "$ABSOLUTE_EXTRACTION_DIR" --strip 1 && RC=0 || RC=1
elif [[ $ABSOLUTE_TARGET_PATH == *.tar.xz ]]; then
  echo "tar -Jxf '$ABSOLUTE_TARGET_PATH' --directory '$ABSOLUTE_EXTRACTION_DIR' --strip 1"
  tar -Jxf "$ABSOLUTE_TARGET_PATH" --directory "$ABSOLUTE_EXTRACTION_DIR" --strip 1 && RC=0 || RC=1
elif [[ $ABSOLUTE_TARGET_PATH == *.tar ]]; then
  echo "tar -xf '$ABSOLUTE_TARGET_PATH' --directory '$ABSOLUTE_EXTRACTION_DIR' --strip 1"
  tar -xf "$ABSOLUTE_TARGET_PATH" --directory "$ABSOLUTE_EXTRACTION_DIR" --strip 1 && RC=0 || RC=1
elif [[ $ABSOLUTE_TARGET_PATH == *.zip ]]; then
  echo "unzip '$ABSOLUTE_TARGET_PATH' -d '$ABSOLUTE_EXTRACTION_DIR'"
  unzip "$ABSOLUTE_TARGET_PATH" -d "$ABSOLUTE_EXTRACTION_DIR"
else
  echo "error 66: unknown archive format"
  RC=66
fi

if [ "$RC" -ne 0 ]; then
  echo "Error($RC) Failed to extract archive: $ABSOLUTE_TARGET_PATH"
  exit $RC
fi

echo "Deleting: $ABSOLUTE_TARGET_PATH"
rm "$ABSOLUTE_TARGET_PATH"

if [ -n "$ABSOLUETE_TARGET_SHA256_PATH" ]; then
  echo "Deleting: $ABSOLUTE_TARGET_PATH"
  rm "$ABSOLUETE_TARGET_SHA256_PATH"
fi
