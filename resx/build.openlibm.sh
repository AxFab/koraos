#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

NAME=openlibm
GIT=https://github.com/JuliaMath/openlibm
FULL_HOST=i386-pc-kora
HOST=i386-kora
VERSION=v0.7.0
GIT_TAG=v0.7.0


# ----------------------------------------------------------------------------
# Clone the sources
if [ ! -d "${SCRIPT_HOME}/3rd_parties/${NAME}" ]; then
    mkdir -p "${SCRIPT_HOME}/3rd_parties"
    cd "${SCRIPT_HOME}/3rd_parties"
    git clone "$GIT" "$NAME"
fi

# Checkout required version
cd "${SCRIPT_HOME}/3rd_parties/${NAME}"
git co "$GIT_TAG"

# Clean previous build
rm -rf "${HOST}-build"
mkdir "${HOST}-build"
mkdir -p "${HOST}-build/usr/lib"
mkdir -p "${HOST}-build/usr/include"


# cp -v ./scripts/pnglibconf.h.prebuilt pnglibconf.h

# Build the library
# TODO -- APPLY PATCH
make ARCH=i386 USEGCC=1 TOOLPREFIX=i386-kora- CFLAGS='-D_GNU_SOURCE' DSTDIR=./${HOST}-build/usr prefix=./${HOST}-build/usr install
sed "s%./${HOST}-build%%" -i ./${HOST}-build/usr/lib/pkgconfig/openlibm.pc
cp ./${HOST}-build/usr/lib/libopenlibm.so ./${HOST}-build/usr/lib/libm.so

# Create package
REPODIR="${SCRIPT_HOME}/packages/${FULL_HOST}"
cd "${HOST}-build/usr"
mkdir -p "$REPODIR"
tar cvJf "$REPODIR/$NAME-$VERSION.tar.xz" *


