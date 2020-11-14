#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

NAME=libpng
GIT=git://git.code.sf.net/p/libpng/code
VERSION=v1.6.37
GIT_TAG=v1.6.37
SUMMARY='A massively spiffy yet delicately unobtrusive compression library'

. "${SCRIPT_DIR}/build-utils.sh"

open_source
cleanup

# ----------------------------------------------------------------------------

SOURCES="
png.c
pngerror.c
pngget.c
pngmem.c
pngpread.c
pngread.c
pngrio.c
pngrtran.c
pngrutil.c
pngset.c
pngtrans.c
pngwio.c
pngwrite.c
pngwtran.c
pngwutil.c
"

HEADERS="png.h pngconf.h pnglibconf.h"


SOURCES=`echo "$SOURCES" | tr '\n' ' '`


# Build the library
cd "${SCRIPT_HOME}/3rd_parties/${NAME}"

cp -RpP -f ./scripts/pnglibconf.h.prebuilt pnglibconf.h


# Build the library
INC_DIRS=-I../zlib/${HOST}-build/usr/include
RPATH=-L${SCRIPT_HOME}/build-i386-pc-kora/kora-os/usr/lib
RAPTH+=" -Wl,-rpath-link=${SCRIPT_HOME}/build-i386-pc-kora/kora-os/usr/lib"
${HOST}-gcc -shared -o "./${HOST}-build/usr/lib/libpng.so" $SOURCES -D_GNU_SOURCE -fPIC ${INC_DIRS} ${RPATH} -lz -ggdb
# ../configure --host=${HOST} --prefix=./${HOST}-build/usr

# Copy headers
cp -RpP -f "png.h" "${HOST}-build/usr/include/png.h"
cp -RpP -f "pngconf.h" "${HOST}-build/usr/include/pngconf.h"
cp -RpP -f "pnglibconf.h" "${HOST}-build/usr/include/pnglibconf.h"

# ----------------------------------------------------------------------------

write_pkgconfig png
create_package

ls -l "$REPODIR/$NAME-$VERSION.tar.xz"
