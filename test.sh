#!/bin/bash
#
# This script tests ./patchwork
#

set -o nounset
set -o errexit

tdir=".test"

local_usage_() {
    cat "$0" |grep "^local_\S\+()" |sed "s,^local_\|_().*,,g" |
        xargs >&2 echo "arguments:"
}

local_check_integrity_() {
    echo "[looking for referred but missing patches, watch for ERRORs]"
    egrep "^\s+(check_patch|show_patch)\s" "./patchwork" |
        while read a b x d; do
            ls -1 patches |grep --color $x || echo ":: ERROR: $x"
        done
    echo
    echo "[looking for existing but not used patches, watch for ERRORs]"
    ls -1 patches/*__*.patch |
        sed -r "s,^([^_]*__(.*)\.patch)$,\2 \1," |
        while read x n; do
            egrep "^\s+(check_patch|show_patch)\s" "./patchwork" |sed "s,^\s*,," |
                egrep --color "\<$x\>" || echo ":: ERROR: $n"
        done
}

local_mk_kernel_() {
    local kver="${1:-${KERNEL_VER:-v4.4}}"
    local kcfg="$(readlink -f "./min-kernel-config")"
    [ ! -e ./.cross-environment ] ||
        source ./.cross-environment
    pushd "${KDIR:?Missing test kernel repository}"
    make mrproper
    git checkout $kver
    KCONFIG_ALLCONFIG="$kcfg" make allnoconfig
    time make -j8
    popd
}

local_clean_fetch_() {
    rm -rf $tdir
    OUT_DIR=$tdir ./fetch-driver-sources.sh
}

local_package_() {
    # depends on clean_get_src
    pushd $tdir/
    tar czf "most-linux-driver-$(cat most/.version).tgz" *
    popd
}

local_patch_() {
    # depends on clean_get_src
    cp -t $tdir/ ./patchwork # update
    [ ! -e ./.cross-environment ] ||
        source ./.cross-environment
    cd $tdir
    ./patchwork patch
    cd ..
}

local_make_() {
    # depends on clean_get_src, patch
    [ ! -e ./.cross-environment ] ||
        source ./.cross-environment
    cp -t $tdir/ Makefile # update
    make -C $tdir -f Makefile
}

local_for_all_kernels_() {
    local l=".logs"
    mkdir -p "$l"
    for v in v4.{4..20} v5.{0..4}; do
        echo
        echo "=== $v ==="
        echo
        local_mk_kernel_ $v
        local_clean_fetch_
        local_patch_
        mv $tdir/.make.log "$l/make-patches-$v.log"
        mv $tdir/.patched "$l/patch-list-$v.list"
        local_make_ 2>&1 |tee "$l/make-modules-$v.log"
    done
}

for test in "${@:-"usage"}"; do local_${test}_; done
