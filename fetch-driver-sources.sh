#!/bin/bash
#
# This script fetches all relevant MOST Linux Driver sources files
# from the github repository.
#
# Usage:
#   [OUT_DIR=<NON-EXISTING-OUTPUT-DIRECTORY>] "$0"
#

set -o nounset
set -o errexit

TAG="v5.3"
PRJ=https://github.com/microchip-ais/linux/raw
GIT_REPO=https://github.com/microchip-ais/linux.git

_err() {
    echo "ERROR: $@" >&2
    exit 1
}

_get_file() {
    local SRC=${PRJ}/${TAG}/$1
    local DST=./$2
    echo "wget ${SRC} ..."
    mkdir -p "$(echo "${DST}" |sed -r "s,/[^/]+$,,")"
    wget --quiet -O "${DST}" "${SRC}"
}

get_src() {
    _get_file "drivers/staging/most/$1" "$1" || _err "failed"
}

get_mld_files() {
    get_src Documentation/driver_usage.txt
    get_src Documentation/ABI/sysfs-bus-most.txt
    get_src Documentation/ABI/configfs-most.txt
    get_src Documentation/ABI/sysfs-class-most.txt

    get_src core.c
    get_src core.h
    get_src configfs.c

    get_src video/video.c
    get_src net/net.c
    get_src cdev/cdev.c
    get_src sound/sound.c

    get_src dim2/reg.h
    get_src dim2/hal.h
    get_src dim2/dim2.c
    get_src dim2/sysfs.h
    get_src dim2/hal.c
    get_src dim2/errors.h
    get_src dim2/sysfs.c
    get_src i2c/i2c.c
    get_src usb/usb.c
}

main() {
    which wget >/dev/null || _err "wget is not installed"

    mkdir "${OUT_DIR:=$(date "+%F-%H%M%S")-$TAG}"

    mkdir "$OUT_DIR"/{patches,most}

    cp -a -t "$OUT_DIR"/patches patches/*
    cp -a -t "$OUT_DIR" Makefile patchwork

    cd "$OUT_DIR"/most

    get_mld_files

    echo "add version info ..."
    LABEL="$(git ls-remote $GIT_REPO |grep "/${TAG}$" |sed "s,\s.*,,")"
    echo "$TAG" >.version

    [ "$LABEL" != "$TAG" ] || LABEL=""
    sed -i -r -e "/__init/,/return/s,\<pr_.*init.*,pr_info(\"MOST Linux Driver $TAG ${LABEL}\\\\n\");," \
        core.c
    grep --with-filename "MOST Linux Driver " core.c ||
        _err "failed to set driver version info"

    cd ..

    echo "output directory: $OUT_DIR"
}

main
