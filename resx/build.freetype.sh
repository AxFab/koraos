#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

NAME=freetype
GIT=git://git.sv.nongnu.org/freetype/freetype2.git
VERSION=v2.10.2
GIT_TAG=VER-2-10-2
SUMMARY='FreeType is a font service library'

. "${SCRIPT_DIR}/build-utils.sh"

open_source
cleanup

# ----------------------------------------------------------------------------

SOURCES="
src/autofit/autofit.c
src/base/ftbase.c
src/base/ftbbox.c
src/base/ftbdf.c
src/base/ftbitmap.c
src/base/ftcid.c
src/base/ftdebug.c
src/base/ftfstype.c
src/base/ftgasp.c
src/base/ftglyph.c
src/base/ftgxval.c
src/base/ftinit.c
src/base/ftmm.c
src/base/ftotval.c
src/base/ftpatent.c
src/base/ftpfr.c
src/base/ftstroke.c
src/base/ftsynth.c
src/base/ftsystem.c
src/base/fttype1.c
src/base/ftwinfnt.c
src/bdf/bdf.c
src/cache/ftcache.c
src/cff/cff.c
src/cid/type1cid.c
src/gzip/ftgzip.c
src/lzw/ftlzw.c
src/pcf/pcf.c
src/pfr/pfr.c
src/psaux/psaux.c
src/pshinter/pshinter.c
src/psnames/psmodule.c
src/raster/raster.c
src/sfnt/sfnt.c
src/smooth/smooth.c
src/truetype/truetype.c
src/type1/type1.c
src/type42/type42.c
src/winfonts/winfnt.c
"


SOURCES=`echo "$SOURCES" | tr '\n' ' '`


# Build the library
INC_DIRS=-Iinclude
${HOST}-gcc -shared -o "./${HOST}-build/usr/lib/libfreetype.so" $SOURCES -D_GNU_SOURCE -fPIC ${INC_DIRS} -D_LIB -DFT2_BUILD_LIBRARY -DDLL_EXPORT
# ../configure --host=${HOST} --prefix=./${HOST}-build/usr

# Copy headers
cp -vr "include" "${HOST}-build/usr/include"

# ----------------------------------------------------------------------------

write_pkgconfig freetype
create_package

ls -l "$REPODIR/$NAME-$VERSION.tar.xz"
