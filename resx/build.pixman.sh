#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

NAME=pixman
GIT=git://anongit.freedesktop.org/git/pixman.git
FULL_HOST=i386-pc-kora
HOST=i386-kora
VERSION=v0.40.0
GIT_TAG=pixman-0.40.0

SOURCES="
pixman/pixman-access-accessors.c
pixman/pixman-access.c
pixman/pixman-arm.c
pixman/pixman-bits-image.c
pixman/pixman-combine-float.c
pixman/pixman-combine32.c
pixman/pixman-conical-gradient.c
pixman/pixman-edge-accessors.c
pixman/pixman-edge.c
pixman/pixman-fast-path.c
pixman/pixman-filter.c
pixman/pixman-general.c
pixman/pixman-glyph.c
pixman/pixman-gradient-walker.c
pixman/pixman-image.c
pixman/pixman-implementation.c
pixman/pixman-linear-gradient.c
pixman/pixman-matrix.c
pixman/pixman-mips.c
pixman/pixman-noop.c
pixman/pixman-ppc.c
pixman/pixman-radial-gradient.c
pixman/pixman-region16.c
pixman/pixman-region32.c
pixman/pixman-solid-fill.c
pixman/pixman-timer.c
pixman/pixman-trap.c
pixman/pixman-utils.c
pixman/pixman-x86.c
pixman/pixman.c
"

HEADERS="
pixman/pixman-accessor.h
pixman/pixman-combine32.h
pixman/pixman-compiler.h
pixman/pixman-edge-imp.h
pixman/pixman-inlines.h
pixman/pixman-private.h
pixman/pixman.h
"


SOURCES=`echo "$SOURCES" | tr '\n' ' '`
HEADERS=`echo "$HEADERS" | tr '\n' ' '`

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


sed pixman/pixman-version.h.in -e 's/@PIXMAN_VERSION_MAJOR@/0/' -e 's/@PIXMAN_VERSION_MINOR@/40/' -e 's/@PIXMAN_VERSION_MICRO@/0/' > pixman/pixman-version.h

# Build the library
INC_DIRS=-I./pixman
# INC_DIRS=-I../zlib/${HOST}-build/usr/include
${HOST}-gcc -shared -o "./${HOST}-build/usr/lib/libpixman.so" $SOURCES -D_GNU_SOURCE -DPIXMAN_NO_TLS -fPIC ${INC_DIRS} -DPACKAGE=1 -DPACKAGE_VERSION=1
# ../configure --host=${HOST} --prefix=./${HOST}-build/usr

# Copy headers
for f in $HEADERS; do
    mkdir -p `dirname "${HOST}-build/usr/include/${f}"`
    cp -v "$f" "${HOST}-build/usr/include/${f}"
done

# Create package
REPODIR="${SCRIPT_HOME}/packages/${FULL_HOST}"
cd "${HOST}-build/usr"
mkdir -p "$REPODIR"
tar cvJf "$REPODIR/$NAME-$VERSION.tar.xz" *


