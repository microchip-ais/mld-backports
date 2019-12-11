#!/bin/bash

set -o nounset
set -o errexit

tdir=".test"

fail_() {
    >&2 echo "$@"; exit 1
}

check_git_dir_() {
    [ -d $tdir/.git ] || fail_ "$tdir: no .git directory found, use $0 init"
}

git_diff_() {
    local pwd="$(pwd)"
    cd $tdir
    git diff
    cd "$pwd"
}

init() {
    pushd $tdir
    [ -d .git ] || { git init && git add most && git commit -m-; }
    popd
}

new() {
    local PATCH="${1:?missing patch name}"

    check_git_dir_

    echo "${PATCH}" >.name
    printf "backport: x\n\n" >.head
    update
}

apply() {
    local PATCH="${1:?missing patch name}"

    check_git_dir_

    echo "${PATCH}" >.name
    cat "$PATCH" |sed -n "1,/^diff /p" |grep -v "^diff " >.head
    cat "$PATCH" |patch -d $tdir -p1
}

update() {
    check_git_dir_

    git_diff_ |grep --max-count=1 -q ^ || fail_ "$tdir: diff is empty"

    { git_diff_ |grep -v "^index " ||:; } |
        tee -a .head |patch -R -d $tdir -p1

    mv .head "$(cat .name)"
    rm .name
}

list() {
    local filter="${1:-^}"
    ls -1 patches/*.patch |grep "$filter"
}

check() {
    check_git_dir_
    list "$@" |while read x; do
        echo "[$x]"
        cat $x |patch --dry-run -d $tdir -p1
        echo
    done
}

update_all() {
    check_git_dir_
    list "$@" |while read x; do
        echo "[$x]"
        apply "$x"
        update
        echo
    done
}

usage() {
    echo "parameters: list {filter} | check {filter} | new <patch> | apply <patch> | update | update_all {filter}"
    check_git_dir_
}

"${@:-"usage"}"
