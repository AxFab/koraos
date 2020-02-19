#!/bin/bash

SCRIPT_DIR=`dirname $BASH_SOURCE{0}`
SCRIPT_HOME=`readlink -f $SCRIPT_DIR`

function git_do {
    NAME=$1
    if [ ! -d "$SCRIPT_HOME/sources/$NAME" ]; then
        return
    fi
    shift

    echo "------------------------------"
    echo "# -- $NAME"
    git -C $SCRIPT_HOME/sources/$NAME "$@"
}


NAME=$1
if [ -d "$SCRIPT_HOME/sources/$NAME" ]; then
    shift
    git_do $NAME "$@"
else
    # for dir in `ls $SCRIPT_HOME/sources`; do
    #     git_do "$dir" "$@"
    # done

    git_do kernel "$@"

    git_do file-systems "$@"
    git_do drivers-pc "$@"
    git_do drivers-misc "$@"

    git_do libc "$@"
    git_do lgfx "$@"
    git_do gum "$@"

    git_do utils "$@"
    git_do krish "$@"
    git_do desktop "$@"
fi

