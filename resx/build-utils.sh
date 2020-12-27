
if [ -z "${GIT_TAG}" ]; then
    GIT_TAG="${VERSION}"
fi

HOST=i386-kora
FULL_HOST=`${SCRIPT_HOME}/make/host.sh ${HOST}`

function open_source {
    # Clone the sources
    if [ ! -d "${SCRIPT_HOME}/3rd_parties/${NAME}" ]; then
        mkdir -p "${SCRIPT_HOME}/3rd_parties"
        cd "${SCRIPT_HOME}/3rd_parties"
        git clone "$GIT" "$NAME"
    fi

    # Checkout required version
    cd "${SCRIPT_HOME}/3rd_parties/${NAME}"
    git co "$GIT_TAG"

}

function cleanup {
    cd "${SCRIPT_HOME}/3rd_parties/${NAME}"
    # Clean previous build
    rm -rf "${HOST}-build"
    mkdir "${HOST}-build"
    mkdir -p "${HOST}-build/usr/lib"
    mkdir -p "${HOST}-build/usr/include"
}

function write_pkgconfig {
    cd "${SCRIPT_HOME}/3rd_parties/${NAME}"
    mkdir -p "${HOST}-build/usr/lib/pkgconfig"
    cat > "${HOST}-build/usr/lib/pkgconfig/${NAME}.pc" << EOF
prefix=/usr
version=${VERSION}
exec_prefix=\${prefix}
includedir=\${prefix}/include
libdir=\${exec_prefix}/lib

Name: ${NAME}
Version: \${version}
URL: ${GIT}
Description: ${SUMMARY}
Cflags: -I\${includedir}
Libs: -L\${libdir} -l$1
EOF

}

function create_package {
    cd "${SCRIPT_HOME}/3rd_parties/${NAME}"
    # Create package
    REPODIR="${SCRIPT_HOME}/packages/${FULL_HOST}"
    cd "${HOST}-build/usr"
    mkdir -p "$REPODIR"
    tar cvJf "$REPODIR/$NAME-$VERSION.tar.xz" *
}



