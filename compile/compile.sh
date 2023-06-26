#!/bin/bash -e

compile_env() {
    # prefix is the target dir
    echo "COMPILE_INIT_ARG         = $COMPILE_INIT_ARG"
    echo "COMPILE_NAME             = $COMPILE_NAME"
    echo "BUILD_TYPE               = $BUILD_TYPE"
    echo "SRC_DIR                  = $SRC_DIR"
    echo "PATCH_DIR                = $PATCH_DIR/$TARGET"
    echo "PREFIX                   = $PREFIX"
    echo "TARGET                   = $PREFIX/$TARGET"
    echo "PKG_CONFIG_PATH          = $PKG_CONFIG_PATH"
    echo "LDFLAGS                  = $LDFLAGS"
    echo "CFLAGS                   = $CFLAGS"
    echo "CPPFLAGS                 = $CPPFLAGS"
    echo "CC                       = $CC"
    echo "CORES                    = $CORES"
    echo "MAKEFLAGS                = $MAKEFLAGS"
    echo "TMP_DIR                  = $TMP_DIR"
    echo "THIRD_DIR                = $THIRD_DIR"
    echo "PACKAGES_DIR             = $PACKAGES_DIR"
    echo "LOGS_DIR                 = $LOGS_DIR"
    sleep 3
}

mk_build_dir() {
    mkdir -p $BUILD_DIR
}

cd_src_dir() {
    # show environment variables
    compile_env
    echo "Switching into source directory: $SRC_DIR"
    cd "$SRC_DIR"
}

collect_logs() {
    LOGFILES="$(find . -type f -name "*.log")"
    echo ""
    echo "===== COLLECTING LOGS ====="
    for LOGFILE in $LOGFILES
    do
        TARGET_FILE="$LOGS_DIR/$BUILD_TYPE/$COMPILE_NAME/$LOGFILE"
        LOG_DIR="$(dirname "$TARGET_FILE")"
        LOG_NAME="$(basename "$TARGET_FILE")"

        mkdir -p "$LOG_DIR"
        TARGET_FILE="$( cd "$LOG_DIR" && pwd )/$LOG_NAME"
        cp "$LOGFILE" "$TARGET_FILE"
    done
    echo ""
}

start() {
    export compile_start=$SECONDS
}

stop() {
    duration=$(( SECONDS - compile_start ))
    collect_logs
    echo "Compilation of '$TARGET' took $duration seconds"
    echo "GNU_RC=$RC"
}

# explicit_bzero requires Version >= 2.24
glibc_force_version() {
    VERSION=$1

    echo "Forcing linking to 'force_link_glibc_$VERSION.h"
    CFLAGS+=" -include $SRC_DIR/lib/glibc-force/version_headers/x64/force_link_glibc_$VERSION.h"
    CPPFLAGS+=" -include $SRC_DIR/lib/glibc-force/version_headers/x64/force_link_glibc_$VERSION.h"
}

# return a list of -l(libname w/o lib prefix and w/o .a suffix) flags as single line from TARGET_PATH
all_libs64() {
    TARGET_PATH=$1
    # find files and get their base name, fetch only files containing lib(.*64).a, add -l prefix, collapse lines into a single line
    find $TARGET_PATH -type f -exec basename {} \; | grep -oP 'lib\K(.*64)(?=\.a|\.so[\.\d]*)' | sort | uniq | sed -e 's~^~-l~' | tr -s "\n" " "
}

# return a list of -l(libname w/o lib prefix and w/o .a suffix) flags as single line from TARGET_PATH
all_libs() {
    TARGET_PATH=$1
    # find files and get their base name, fetch only files containing lib(.*64).a, add -l prefix, collapse lines into a single line
    find $TARGET_PATH -type f -exec basename {} \; | grep -oP 'lib\K(.*)(?=\.a|\.so[\.\d]*)' | sort | uniq | sed -e 's~^~-l~' | tr -s "\n" " "
}

force_static_libs() {
    TARGET_PATH=$1
    find $TARGET_PATH -type f -exec basename {} \; | grep -oP 'lib(.*\.a)$' | sort | sed -e 's~^~-l:~' | tr -s "\n" " "
}

force_static_libs64() {
    TARGET_PATH=$1
    find $TARGET_PATH -type f -exec basename {} \; | grep -oP 'lib(.*64\.a)$' | sort | sed -e 's~^~-l:~' | tr -s "\n" " "
}

rm_shared_libs() {
    DIR=$1
    SO_REGEX='.*\.so[\d\.]*$'

    echo "Removing shared libraries from $DIR"
    find "$DIR" -type l | grep -P "$SO_REGEX" | while read -r file ; do
        echo "Removing symlink $file"
        rm -f "$file" && RC=0 || RC=1
    done

    find "$DIR" -type f | grep -P "$SO_REGEX" | while read -r file ; do
        echo "Removing shared library $file"
        rm -f "$file" && RC=0 || RC=1
    done
}

# Expecting a single agument that is the file path w/o the .sh extension
init() {
    SRC_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../src")
    PATCH_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../patch")
    THIRD_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../3rd")
    PACKAGES_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../packages")
    LOGS_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../logs")
    TMP_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../tmp")

    # if prefix is not set use default directory, otherwise use prefix directory
    if [[ -z "$PREFIX" ]]; then
        BUILD_DIR=$(realpath "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../build")
    else
        BUILD_DIR="$PREFIX"
    fi

    export PREFIX="$BUILD_DIR"
    export TARGET="$(echo $1 | rev | cut -d'/' -f-2 | rev)"
    export SRC_DIR="$SRC_DIR/$TARGET"

    export ALL_LIBS="$(all_libs $PREFIX/lib)"
    export ALL_LIBS64="$(all_libs64 $PREFIX/lib)"
    export ALL_STATIC_LIBS="$(force_static_libs $PREFIX/lib)"
    export ALL_STATIC_LIBS64="$(force_static_libs64 $PREFIX/lib)"

    export COMPILE_INIT_ARG="$1"
    export COMPILE_NAME=$(basename $COMPILE_INIT_ARG)

    if [[ -z "$CORES" ]]; then
        export CORES="$(getconf _NPROCESSORS_ONLN)"
    else
       export CORES="$CORES"
    fi

    export MAKEFLAGS+="-j$CORES"
    export PKG_CONFIG_PATH="$PREFIX/lib64/pkgconfig:$PREFIX/lib/pkgconfig"
    export PATH="$PREFIX/bin:$PATH"
    export BUILD_TYPE="$(basename $(dirname "$SRC_DIR"))"
    export LDFLAGS=" -Bstatic -L$PREFIX/lib64 -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib64,-rpath,$PREFIX/lib"
    export CFLAGS=" -m64 -fPIC -I$PREFIX/include "
    export CPPFLAGS=" -I$PREFIX/include "
    export CC="gcc"
    export PATCH_DIR="$PATCH_DIR/$TARGET"
    export THIRD_DIR="$THIRD_DIR"
    export MODULES_DIR="$MODULES_DIR"
    export LOGS_DIR="$LOGS_DIR"
    export TMP_DIR="$TMP_DIR"

    # abort in case tha the source directory is empty
    if [ -n "$(ls -A $SRC_DIR 2>/dev/null)" ]
    then
        echo "Found source files in: $SRC_DIR"
    else
        echo "Source directory is empty: $SRC_DIR"
        return 1
    fi

    start
}

# patch file1.patch [file2.patch]
patch() {
    FILES="$@"
    for FILE in $FILES
    do
        PATCH_FILE="$PATCH_DIR/$FILE"
        echo "===== PATCHING ====="
        echo "SRC_DIR    = $(pwd)"
        echo "PATCH_FILE = $PATCH_FILE"
        git apply --stat "$PATCH_FILE"
        git apply --check "$PATCH_FILE"
        echo "===== PATCHING ====="
    done
}


files_before_build() {
    echo "Cleaning up: $TMP_DIR/*.txt"
    rm -f "$TMP_DIR/*.txt"

    BEFORE_FILE="$TMP_DIR/module_files_before_build.txt"
    echo "Looking for files in $PREFIX and writing result to $BEFORE_FILE"
    find $PREFIX -type f | sort -k 2 > $BEFORE_FILE
}


diff_and_package_files() {
    BEFORE_FILE="$TMP_DIR/module_files_before_build.txt"
    AFTER_FILE="$TMP_DIR/module_files_after_build.txt"
    INCLUDE_FILE="$TMP_DIR/module_files.txt"

    TARGET_DIR="$PACKAGES_DIR/$BUILD_TYPE"
    TARGET="$TARGET_DIR/$COMPILE_NAME.tar.gz"

    echo "Files in $PREFIX -> $AFTER_FILE"
    find $PREFIX -type f | sort -k 2 > $AFTER_FILE

    echo "Diff from $BEFORE_FILE and $AFTER_FILE -> $INCLUDE_FILE"
    diff -u $BEFORE_FILE $AFTER_FILE | grep -oP '^\+\K[^+].*' > $INCLUDE_FILE || true

    echo "Creating target dir: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"

    echo "Packaging $PREFIX ($INCLUDE_FILE) -> $TARGET"
    tar --owner=0 --group=0 -czf "$TARGET" --files-from="$INCLUDE_FILE" 2> /dev/null
}

