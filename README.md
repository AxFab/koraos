# Kora OS - Distribution workspace

KoraOs is a hobbyst OS.


The KoraOs system is composed of several components.

 - [Kernel](https://github.com/axfab/kora-kernel)
 - [Libc](https://github.com/axfab/kora-libc)
 - [File-systems](https://github.com/axfab/kora-filesystems)
 - [Drivers PC](https://github.com/axfab/kora-driver-pc)
 - [Utilities](https://github.com/axfab/kora-utils)
 - [Desktop](https://github.com/axfab/kora-desktop)
 - And more...

The repositories have been created to keep small components that take
care of one ascpect of the system.

Also many component are made to run on other platform and can be run and
tested as a unit.


## Hacking and building

The repositories can all be compiled test and used on their own, but to truly
use the kora system, you will be better to download the `koraos` package.

```
git clone https://github.com/axfab/koraos
```

This one is quitte small but create an environment for development and
distribution compilation. It rely on a dummy package manager that will be able
to use already compiled package or update just the source that did changes.

The overall might be quitte derouting at first, but it's the best I found to
reduce the complexity of the full system.



## Building the System from scratch

Building the full system is a complex task, it require a custom toolchain,
we also have several packages to move arround, the boot image to create and
third party software to compile.

The dumbest way of creating an image is `./disto.sh build`. However by default
you won't compile anything, just download and regroup pre-compiled packages.
To recompile alls, the simplest way is:

```
./disto.sh toolchain
./disto.sh reset-source
./disto.sh setup
./disto.sh third_parties
./disto.sh build
```

It sequencialy do 5 things:

 - First it download and recompile the toolchain.
 - Then it will rewrite the `config.yml` file and setup all kora-package to be
build from sources.
 - The third command will ask for re-install the libc and headers on the toolchain, you need the last one from the sources.
 - The fourth will download and re-packages all third parties.
 - Last one, it recompile everything and create an iso image.


## Organisation of the working space

The repository is not a real source repository but a pre-configure workspace
to build a custom system image.

We can find all kora package into the `sources/` directory. If you wanna edit
code, that the place to look at.

The `package/` directory is a cache for all download packages. You might look
for archived package there, but all writing should be done by the `pkg.sh`
script. I'm quite proud of my Dropbox based package manager!

The directories `build-{target}/` are were all intermediate files goes to
create deliveries and packages.

The `3rd_parties/` hold sources for external libraries.

The `resx/` contains utilities scripts.



