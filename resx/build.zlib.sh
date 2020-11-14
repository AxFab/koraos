#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

NAME=zlib
GIT=https://github.com/madler/zlib
VERSION=v1.2.11
GIT_TAG=v1.2.11
SUMMARY='A massively spiffy yet delicately unobtrusive compression library'

. "${SCRIPT_DIR}/build-utils.sh"

open_source
cleanup

# ----------------------------------------------------------------------------

SOURCES="
adler32.c
compress.c
crc32.c
deflate.c
gzclose.c
gzlib.c
gzread.c
gzwrite.c
infback.c
inffast.c
inflate.c
inftrees.c
trees.c
uncompr.c
zutil.c
"
SOURCES=`echo "$SOURCES" | tr '\n' ' '`


# Build the library
cd "${SCRIPT_HOME}/3rd_parties/${NAME}"

${HOST}-gcc -shared -o "./${HOST}-build/usr/lib/libz.so" $SOURCES -D_GNU_SOURCE -fPIC -ggdb
# ../configure --host=${HOST} --prefix=./${HOST}-build/usr

# Copy headers
cp -RpP -f "zlib.h" "${HOST}-build/usr/include/zlib.h"
cp -RpP -f "zconf.h" "${HOST}-build/usr/include/zconf.h"

# ----------------------------------------------------------------------------

write_pkgconfig z
create_package

ls -l "$REPODIR/$NAME-$VERSION.tar.xz"
