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

Also many components are made to run on other platform and can be run and
tested as a unit.


## Hacking and building

To compile any deliveries for KoraOS you need to prepare a cross-compilor
toolchain.

This can be done easly with the following scripts:

```
./disto.sh header
./resx/toolchain/build-gcc.sh --prefix=/i386-kora
```

However it require some knowledge to debug some issues.
A simpler way might be to use the docker image which already contains all
the required tools.

```
docker pull axfab/kora-gcc:latest
docker run -v `pwd`:/app -w /app -it axfab/kora-gcc:latest bash
```

Once the toolchain is up and ready it can be update using:

```
./disto.sh setup
```

And the Kora image can be build with:

```
./disto.sh build
```


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


