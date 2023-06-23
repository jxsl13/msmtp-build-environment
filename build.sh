#!/bin/bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "Starting build process..."

# if prefix is not set use default directory, otherwise use prefix directory
if [[ -z "$PREFIX" ]]; then
    echo 'PREFIX environment variable not set, e.g. /build'
    exit 1
else
    # make absolute path
    PREFIX="$PREFIX"
fi
export PREFIX;

echo "PREFIX = $PREFIX"
echo "Removing directory $PREFIX"
rm -rf "$PREFIX"
echo "Creating directory $PREFIX"

rm -rf "$SCRIPT_DIR/tmp" "$SCRIPT_DIR/logs"
mkdir -p "$SCRIPT_DIR/tmp" "$SCRIPT_DIR/src" "$PREFIX" "$PREFIX/bin" "$PREFIX/include" "$PREFIX/lib" "$PREFIX/share"
sleep 5


log_errors() {
    CMD=$@
    FILE_NAME="$(basename ${CMD%.*})"

    LOGS_DIR="./logs"
    mkdir -p "$LOGS_DIR"

    LOG_PREFIX="$LOGS_DIR/${FILE_NAME}"
    LOG_NAME="${LOG_PREFIX}.log"
    LOG_NAME_ERRORS="${LOG_PREFIX}_error.log"

    printf "############\n############\n############\n############\n START: $CMD ############\n############\n############\n############\n"
    # pipe errors into an error log file and normal output into another file as well as into stdout
    $CMD 2> $LOG_NAME_ERRORS | tee $LOG_NAME
    RC=$?
    printf "############\n############\n############\n############\n END: $CMD ############\n############\n############\n############\n"

    if [ $RC -eq 0 ]; then
        # try to find our echo output
       grep 'GNU_RC=0' $LOG_PREFIX*
       RC=$?
    fi

    # abort on error
    if [ $RC -ne 0 ]; then
        printf "#### Errors($RC): ####\n"
        cat "$LOG_NAME_ERRORS"
        printf "#### Errors($RC): ####\n"
        return $RC
    fi

    EMPTY=1
    grep -q '[^[:space:]]' < "$LOG_NAME_ERRORS" && EMPTY=0
    if [ $EMPTY -ne 0 ]; then
        # The file is not-empty.
        rm -f "$LOG_NAME_ERRORS"
    fi

    return $RC
}

# build tools gettext, autoconf & texinfo first
# followed by libraries
log_errors ./compile/bin/./gettext.sh &&
log_errors ./compile/bin/./autoconf.sh &&
log_errors ./compile/bin/./texinfo.sh &&
\
log_errors ./compile/lib/./zlib.sh &&
log_errors ./compile/lib/./gmp.sh &&
log_errors ./compile/lib/./expat.sh &&
log_errors ./compile/lib/./libxml.sh &&
log_errors ./compile/lib/./nettle.sh &&
log_errors ./compile/lib/./openssl.sh &&
\
log_errors ./compile/lib/./libidn.sh &&
log_errors ./compile/lib/./libidn2.sh &&
log_errors ./compile/lib/./libntlm.sh &&
log_errors ./compile/lib/./gss.sh &&
log_errors ./compile/lib/./libgsasl.sh &&
\
log_errors ./compile/bin/./curl.sh &&
log_errors ./compile/bin/./wget.sh &&
log_errors ./compile/bin/./msmtp.sh &&
RC=0 || RC=1

echo "Build finished with return code: $RC"
exit $RC
