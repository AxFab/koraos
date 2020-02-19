#!/bin/bash

set -eu

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR"`
TOPDIR=`pwd`

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

CSL_RED='\033[0;31m'
CSL_YELLOW='\033[0;33m'
CSL_CYAN='\033[0;36m'
CSL_OFF='\033[0m'

function echo_info {
    while (( $# > 0)); do
        echo "$1"
        shift
    done
}

function echo_important {
    while (( $# > 0)); do
        echo -e $CSL_CYAN"$1"$CSL_OFF
        shift
    done
}

function echo_warning {
    while (( $# > 0)); do
        echo -e $CSL_YELLOW"$1"$CSL_OFF
        shift
    done
}
function echo_error {
    while (( $# > 0)); do
        echo -e $CSL_RED"$1"$CSL_OFF
        shift
    done
    false
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function update_file {
    hash1=`sha1sum "$1" | cut -f 1 -d ' '`
    hash2=`sha1sum "$2" | cut -f 1 -d ' '`
    if [ "$hash1" != "$hash2" ]; then
        echo "UPDT -- $2"
        cp "$1" "$2"
    fi
}

function update_prj {
    if [ ! -d "$SCRIPT_HOME/sources/$1" ]; then
        echo "No repository at $SCRIPT_HOME/sources/$1"
        return
    fi
    DIR=`readlink -f $SCRIPT_HOME/sources/$1`
    mkdir -p "$DIR/make"
    update_file "$SCRIPT_HOME/make/build.mk" "$DIR/make/build.mk"
    update_file "$SCRIPT_HOME/make/check.mk" "$DIR/make/check.mk"
    update_file "$SCRIPT_HOME/make/global.mk" "$DIR/make/global.mk"
    update_file "$SCRIPT_HOME/make/host.sh" "$DIR/make/host.sh"
    update_file "$SCRIPT_HOME/make/configure" "$DIR/configure"
    update_file "$SCRIPT_HOME/make/LICENSE.md" "$DIR/LICENSE.md"

    update_file "$SCRIPT_HOME/make/x.gitattributes" "$DIR/.gitattributes"
    update_file "$SCRIPT_HOME/make/x.gitignore" "$DIR/.gitignore"

    shift
    while (( $# > 0 )); do
        case $1 in
            --drivers)
                update_file "$SCRIPT_HOME/make/drivers.mk" "$DIR/make/drivers.mk"
                ;;
            *)
                echo "Ignore option $1"
                ;;
        esac
        shift
    done
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function package_clone {
    local SRCDIR="$TOPDIR/sources/$1"

    if [ ! -f "$SRCDIR/Makefile" ]; then
        echo_info "Download sources for $1"
        var=` echo "KORA_cfg_sources_$1" | tr '-' '_'`
        GIT_URL="${!var}"
        mkdir -p "$TOPDIR/sources"
        cd "$TOPDIR/sources"
        git clone "$GIT_URL" "$1"
        cd "$SRCDIR"
        git checkout develop
    fi
}

function package_build {
    local SRCDIR="$TOPDIR/sources/$1"

    if [ ! -f "$GENDIR/Makefile" ]; then # <Todo> Or in case we force rebuild
        echo_info "Configure build at $GENDIR"
        rm -rf "$GENDIR"
        mkdir -p "$GENDIR"
        cd "$GENDIR"
        $SRCDIR/configure --target="$TARGET" --prefix="$PREFIX"
    fi

    echo_info "Build the product $1"
    cd "$GENDIR"
    # make
    make install
}

function package_publish {
    local SRCDIR="$TOPDIR/sources/$1"
    local GENDIR="$TOPDIR/build-$TARGET/$1"
    local PREFIX="$TOPDIR/build-$TARGET/$1/usr"
    local VERS="$2"
    local PACKNAME=$1-$VERS.tar.xz

    package_clone $1
    package_build $1

    echo_info "Create the package $PACKNAME"
    cd "$PREFIX"
    mkdir -p "$REPODIR"
    tar cvJf "$REPODIR/$PACKNAME" *
}

function package_install {
    var=` echo "KORA_cfg_packages_$1" | tr '-' '_'`
    local VERS="${!var}"
    local PACKNAME=$1-$VERS.tar.xz

    echo_info "Package $1 ($VERS)"

    if [ "$VERS" == 'src' ] || [ ! -f "$REPODIR/$PACKNAME" ]; then
        package_publish $1 $VERS
    fi

    local PREFIX="$TOPDIR/build-$TARGET/kora-os"

    echo_info "Install $1 $VERS"
    if [ ! -f "$REPODIR/$PACKNAME" ]; then
        echo_error "Unable to find package $PACKNAME"
    fi
    mkdir -p "$PREFIX"
    cd "$PREFIX"
    tar xvJf "$REPODIR/$PACKNAME"
}

function header_publish {
    package_clone kernel
    package_clone libc

    local VERS="$KORA_cfg_packages_libc"
    if [ "$KORA_cfg_packages_kernel" != "$KORA_cfg_packages_libc" ]; then
        echo_error "In order to package kora headers, kernel and libc source must be on the same version [$KORA_cfg_packages_kernel vs. $KORA_cfg_packages_libc]"
    fi

    local GENDIR="$TOPDIR/build-$TARGET/kora-headers"
    local PACKNAME=kora-headers-$VERS.tar.xz

    local KERN_DIR="$TOPDIR/sources/kernel"
    local LIBC_DIR="$TOPDIR/sources/libc"
    local ARCH=`echo $TARGET | cut -d '-' -f 1`

    rm -rf "$GENDIR/usr"
    mkdir -p "$GENDIR/usr"

    cp -vr "$LIBC_DIR/include" "$GENDIR/usr/"
    # cp -vr "$LIBC_DIR/arch/$ARCH/*" "$TOOL_HEADERS/"
    cp -vr "$KERN_DIR/include/kernel" "$GENDIR/usr/include/"
    cp -vr "$KERN_DIR/arch/$ARCH/include/kernel/arch.h" "$GENDIR/usr/include/kernel"
    cp -vr "$KERN_DIR/arch/$ARCH/include/kernel/cpu.h" "$GENDIR/usr/include/kernel"
    cp -vr "$KERN_DIR/arch/$ARCH/include/kernel/mmu.h" "$GENDIR/usr/include/kernel"

    echo_info "Create the package $PACKNAME"
    cd "$GENDIR"
    mkdir -p "$REPODIR"
    tar cvJf "$REPODIR/$PACKNAME" *
}



# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function for_all_packages {
    "$1" kernel

    "$1" file-systems --drivers
    "$1" drivers-pc --drivers
    "$1" drivers-misc --drivers

    "$1" libc
    "$1" lgfx
    # "$1" gum

    "$1" utils
    "$1" krish
    # "$1" desktop
}

function update_disto {
    echo_info "Update common kora projects files" ""
    for_all_packages update_prj
}


function clone_disto {
    echo_info "Download kora sources repository" ""
    for_all_packages package_clone
}

# Build Kora distribution image
function build_disto {
    echo_info "Build Kora distribution image" ""
    for_all_packages package_install
}

function build_image {
    local PREFIX="$TOPDIR/build-$TARGET/kora-os"

    echo_info "Create boot archive"
    cd "$PREFIX/boot/mods"
    tar cf ../miniboot.tar ata.ko isofs.ko ps2.ko vga.ko

    echo_info "Install grub file"
    mkdir -p "$PREFIX/boot/grub"
    cp "$SCRIPT_HOME/resx/grub.cfg" "$PREFIX/boot/grub/grub.cfg"

    echo_info "Create disk image Kora.iso"
    cd $SCRIPT_HOME
    grub-mkrescue -o Kora.iso "$PREFIX"

    # Library ports
    # openlibm
    # zlib
    # png
    # jpeg
    # bz2
    # freetype2
    # cairo
    # buzybox

    echo_info "  ----"
}

function setup_toolchain {

    local VERS="$KORA_cfg_packages_libc"
    local PACKNAME=kora-headers-$VERS.tar.xz
    if [ "$VERS" == 'src' ]; then
        header_publish
    fi

    if [ -z "$TLSDIR" ]; then
        echo_error "Unable to setup the toolchain"
    fi

    cd "$TLSDIR"
    rm -rf ./usr/include

    tar xvJf "$REPODIR/$PACKNAME"
}


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo_info "KORA DISTRIBUTION" "  ----"

# Load persisted settins
if [ -f "$TOPDIR/disto.yml" ]; then
    echo_info "Use configuration file $TOPDIR/disto.yml"
    # echo `parse_yaml "$TOPDIR/disto.yml" ''`
    source <(parse_yaml "$TOPDIR/disto.yml" 'KORA_cfg_')
fi


TARGET=`$SCRIPT_DIR/make/host.sh "$KORA_cfg_architecture-kora"`
COMMAND=''
TLSDIR=''

# Analyze scripts parameters
while (( $# > 0)); do
    case "$1" in
        --arch=*)
            TARGET=`$SCRIPT_DIR/make/host.sh "${1:7}-kora"`
            ;;
        -*)
            echo_error "Unknown parameter $1"
            ;;
        *)
            if [ -n "$COMMAND" ]; then
                echo_error "Unexpected parameter $1"
            fi
            COMMAND=$1
            ;;
    esac
    shift
done


# Initialize tools
echo_info "Initialize building script"
echo_important "Select target architecture $TARGET"

CHAIN=`echo $TARGET | cut -d '-' -f 1`'-kora'
GCC=`which "$CHAIN-gcc" 2>/dev/null || echo ''`
if [ -n "$GCC" ]; then
    GCC=`readlink -f "$GCC"`
    TLSDIR=`dirname $(dirname "$GCC")`
    echo_info "Found cross toolchain at $TLSDIR"
else
    echo_warning "Unable to find cross toolchain for $CHAIN"
fi

REPODIR="$TOPDIR/packages/$TARGET"
echo_info "  ----"

# Run the command
case "$COMMAND" in
    'build')
        build_disto
        build_image
        ;;
    'update')
        update_disto
        ;;
    'clone')
        clone_disto
        ;;
    'header')
        header_publish
        ;;
    'setup')
        setup_toolchain
        ;;
    'help'|'')
        echo "Script to manage packaging of the kora-os distribution"
        echo ""
        echo "USAGE: $0 <command>"
        echo ""
        echo "  The script haven't been tested to be used outside its directory"
        echo "  All those command behaviours depends on the configuration of ./disto.yml"
        echo ""
        echo "    build         Build the complete OS disk image"
        echo "    update        Update common files of all packages"
        echo "    header        Build the package for kora-headers"
        echo "    setup         Update the toolchain (replace headers)"
        echo "    clone         Clone all sources repositories"
        ;;
    *)
        echo_error "Unknown command $COMMAND"
        ;;
esac

