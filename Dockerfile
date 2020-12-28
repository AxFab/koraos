FROM debian:10-slim
RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gcc \
        g++ \
        libc6-dev \
        bash \
        perl \
        m4 \
        xz-utils \
        lbzip2 \
        make;
RUN set -eu; \
    apt-get install -y \
        git \
        vim \
        grub \
        xorriso;

RUN set -eu; \
    git clone https://github.com/axfab/kora-disto /app

# WORKDIR /i386-kora

RUN set -eu; \
    /app/disto.sh header; \
    /app/resx/toolchain/build-gcc.sh --prefix=/i386-kora --target=i386-kora \
    rm -rf sources/ build-i386-kora/ ;

WORKDIR /app

# CMD ["/bin/bash"]

# COPY . /app

# RUN /app/resx/toolchain/build-gcc.sh --prefix=/usr/local

# cat > .bashrc << EOF
# alias ls='ls --color=auto'
# PS1='\e[31m\u\e[0m@\e[36m\h\e[0m:\w# '
# EOF
# . .bashrc
