#!/bin/bash
# Dummy package manager using my dropbox
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR"`
TOPDIR=`pwd`

. "$SCRIPT_HOME/resx/utils.sh"

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function wfetch {
    NM=`echo $1 | tr '/' '\n' | tail -n 1`
    echo '-> Download '$NM" at https://www.dropbox.com/s/$1"
    if [ -f $NM ]; then
        mv "$NM" "$NM.bak"
        wget $WGET_ARGS https://www.dropbox.com/s/$1 -O "$NM" --no-check-certificate || (mv "$NM.bak" "$NM" && false)
        rm "$NM.bak"
    else
        wget $WGET_ARGS https://www.dropbox.com/s/$1 -O "$NM" --no-check-certificate
    fi
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function pack_identify {
    IFS=':' read -ra TPKG <<< "$1"
    export PNAME=${TPKG[0]}
    export PACK=`echo ${TPKG[0]} | tr '-' '_'`
    export VERS=${TPKG[1]}
    if [ -z "$VERS" ]; then
        K=kpkg_${PACK}_stable
        VERS=${!K}
    fi
    if [ -z "$VERS" ]; then
        VERS='latest'
    fi
    export VERS=`echo $VERS | tr '.' '_'`
    export K=kpkg_${PACK}_${SYSOS}_${ARCH}_${VERS}
    export PACK_KEY=${!K}
    export PACK_NAME=`echo "$PACK_KEY" | cut -d '/' -f 2`
    if [ -z "$PAGE_NAME" ] && [ -n "$LOCAL" ]; then
        export PACK_NAME="${TPKG[0]}-${VERS}.tar.xz"
    fi
    K2=kpkg_${PACK}_${SYSOS}_${ARCH}_${VERS}_sha2
    export PACK_SHA2=${!K2}
}

function pack_download {
    echo_info "Package uniq key : $K"
    if [ -z "$PACK_NAME" ]; then
        PACK_NAME="${PNAME}-${VERS}.tar.xz"
        if [ ! -f "$REPODIR/$PACK_NAME" ]; then
            echo_warning "Unable to find package meta-data"
        fi
        return 0
    fi
    mkdir -p "$REPODIR"
    cd "$REPODIR"
    HASH='--'
    if [ -f "$PACK_NAME" ]; then
        HASH=`sha256sum "$PACK_NAME" | cut -f 1 -d ' '`
    fi
    # echo_info "Compare hash $HASH / $PACK_SHA2"
    if [ "$HASH" != "$PACK_SHA2" ]; then
        wfetch "$PACK_KEY"
    else
        true
        # echo_info "Already up to date"
    fi
}


function pack_install {
    cd "$SCRIPT_HOME/packages/$TARGET"
    NAME=`readlink -f "$PACK_NAME"`
    if [ ! -d "$PREFIX" ]; then
        echo_error "Prefix is not a directory $PREFIX"
    fi
    cd "$PREFIX"
    if [ ! -f "$NAME" ]; then
        echo_error "Unable to locate the package at $NAME"
    fi
    tar xf "$NAME"
}

function pack_uninstall {
    cd "$SCRIPT_HOME/packages/$TARGET"
    NAME=`readlink -f "$PACK_NAME"`
    if [ ! -d "$PREFIX" ]; then
        echo_error "Prefix is not a directory $PREFIX"
    fi
    cd "$PREFIX"
    if [ ! -f "$NAME" ]; then
        echo_error "Unable to locate the package at $NAME"
    fi
    tar tf "$NAME" | xargs rm
}


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function read_store {
    echo_important "Package(s) for $SYSOS $ARCH"
    NM="$SCRIPT_HOME/packages/index.yml"
    parse_yaml "$NM" | grep "$SYSOS"_"$ARCH" | grep -v '_sha2' | sed "s/_"$SYSOS"_"$ARCH".*=.*//"
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if [ -z "$PREFIX" ]; then
    export PREFIX=`readlink -f $TOPDIR`
fi

TARGET=''
COMMAND=''
PACKAGE=''
UPDATE=''
LOCAL=''

# Analyze scripts parameters
while (( $# > 0)); do
    case "$1" in
        -u|--update)
            UPDATE='true'
            ;;
        --prefix=*)
            export PREFIX=`readlink -f ${1:9}`
            ;;
        --local)
            LOCAL='true'
            ;;
        --target=*)
            export TARGET="${1:9}"
            ;;
        -*)
            echo_error "Unknown parameter $1"
            ;;
        *)
            if [ -n "$COMMAND" ]; then
                if [ -n "$PACKAGE" ]; then
                    echo_error "Unexpected parameter $1"
                fi
                PACKAGE=$1
            else
                COMMAND=$1
            fi
            ;;
    esac
    shift
done


# Initialize tools
TARGET=`$SCRIPT_DIR/make/host.sh $TARGET`

echo_info "Initialize package script"
echo_important "Select host architecture $TARGET"

IFS='-' read -ra THST <<< "$TARGET"
ARCH=${THST[0]}
SYSOS=`tr ' ' '-' <<< "${THST[@]:2:${#THST[@]}}" | tr '-' '_'`

REPODIR="$SCRIPT_HOME/packages/$TARGET"
if [ ! -f "$SCRIPT_HOME/packages/index.yml" ]; then
    UPDATE='true'
fi

if [ -n "$UPDATE" ]; then
    mkdir -p "$SCRIPT_HOME/packages"
    cd "$SCRIPT_HOME/packages"
    wfetch "gdz3pssw9kxfm1w/index.yml"
fi
. <(parse_yaml $SCRIPT_HOME/packages/index.yml 'kpkg_')
pack_identify "$PACKAGE"
echo_info "  ----"

# Run the command
case "$COMMAND" in
    'download')
        pack_download
        ;;
    'install')
        if [ -z "$LOCAL" ]; then
            pack_download
        fi
        pack_install
        ;;
    'uninstall')
        pack_uninstall
        ;;
    'update')
        pack_uninstall
        pack_download
        pack_install
        ;;
    'list')
        read_store
        ;;
    'search')
        read_store "$@"
        ;;
    'help'|'')
        echo "Dummy package manager served by Dropbox"
        echo ""
        echo "download <pkg>    Downlaod a package"
        echo "install <pkg>     Downlaod and install a package"
        echo "uninstall <pkg>   Remove all files of a package"
        echo "update <pkg>      Re-install a package with its last version"
        echo "list              List all known package"
        # echo "search <text>     Look for a package or utility nammed like text"
        # echo "upgrade           Upgrade the store (no-use here, automatic)"
        echo ""
        echo "Current settings:"
        echo "prefix='$PREFIX'     arch='$ARCH'     os='$SYSOS'"
        # echo "publish <name, version, url>"
        ;;
    *)
        echo "Unknown command: $1" 1>&2
        echo "Use '$0 help' to get the list of available commands." 1>&2
        exit -1
        ;;
esac

