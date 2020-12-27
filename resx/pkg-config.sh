#!/bin/bash
# ----------------------------------------------------------------------------
set -e

SCRIPT_DIR=`dirname "$BASH_SOURCE{0}"`
SCRIPT_HOME=`readlink -f "$SCRIPT_DIR/.."`
TOPDIR=`pwd`

PREFIX=`readlink -f "${SCRIPT_HOME}/build-i386-pc-kora/kora-os/"`

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function open_pkgconfig {
    . <(less "$1" | sed 's/:\s*\(.*\)/="\1"/')

}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

SHOW=''

# Analyze scripts parameters
for param in "$@"; do
    case "$param" in
        --modversion|--cflags|--cflags-only-I|--cflags-only-other|\
        --libs|--libs-only-L|--libs-only-l|--libs-only-other|\
	    --exists)
            if [ -z "$SHOW" ]; then
                SHOW="$param"
            else
                echo "Ignoring incompatible output option: ${param}" 1>&2
            fi
            ;;
        --version)
            echo "PKG-CONFIG special for kora-os Build"
            exit
            ;;
        -*)
            # echo_error "Unknown parameter $1"
            ;;
    esac
done


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

MVERSION='' # --modversion
CFLAGS_I='' # --cflags-only-I
CFLAGS_O='' # --cflags-only-other
LFLAGS_P='' # --libs-only-L
LFLAGS_L='' # --libs-only-l
LFLAGS_O='' # --libs-only-other

# Read package information
RET=0
for pack in "$@"; do
    case "$pack" in
        --modversion|--cflags|--cflags-only-I|--cflags-only-other|\
        --libs|--libs-only-L|--libs-only-l|--libs-only-other|\
        --exists|--version)
            true
            ;;
        *)
            CFG=''
            if [ -f "${PREFIX}/lib/pkgconfig/${pack}.pc" ]; then
                CFG="${PREFIX}/lib/pkgconfig/${pack}.pc"
            elif [ -f "${PREFIX}/usr/lib/pkgconfig/${pack}.pc" ]; then
                CFG="${PREFIX}/usr/lib/pkgconfig/${pack}.pc"
            else
		        true
                RET=1
                # echo "Package not found ${pack}" 1>&2
            fi

            if [ -f "$CFG" ]; then
                open_pkgconfig "$CFG"
                MVERSION+="${Version} "

                CFLAGS_I+="$Cflags "
                # IFS=' ' read -ra _Cflags <<< "$Cflags"
                # for var in "${_Cflags}"; do
                #     case "$var" in
                #         -I*)
                #             CFLAGS_I+="${var} "
                #             ;;
                #         *)
                #             CFLAGS_O+="${var} "
                #             ;;
                #     esac
                # done

                LFLAGS_P+="$Libs "
                # IFS=' ' read -ra _Libs <<< "$Libs"
                # for var in "${_Libs}"; do
                #     case "$var" in
                #         -L*)
                #             LFLAGS_P+="${var} "
                #             ;;
                #         # -l*)
                #         #     LFLAGS_L+="${var} "
                #         #     ;;
                #         *)
                #             LFLAGS_O+="${var} "
                #             ;;
                #     esac
                # done

            fi
            ;;
    esac
done


# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Display information
case "$SHOW" in
    --modversion)
        echo "$MVERSION"
        ;;
    --cflags)
        echo "$CFLAGS_I $CFLAGS_O"
        ;;
    --cflags-only-I)
        echo "$CFLAGS_I"
        ;;
    --cflags-only-other)
        echo "$CFLAGS_O"
        ;;
    --libs)
        echo "$LFLAGS_P $LFLAGS_L $LFLAGS_O"
        ;;
    --libs-only-L)
        echo "$LFLAGS_P"
        ;;
    --libs-only-l)
        echo "$LFLAGS_L"
        ;;
    --libs-only-other)
        echo "$LFLAGS_O"
        ;;
esac

exit $RET

