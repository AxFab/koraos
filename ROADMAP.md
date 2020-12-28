# Roadmap

## Kernel Issues

- `fcntl` operations are redirected using `inode_t.fop.fcntl` operator. However this operation must be on the made over the `fstream_t` structure.
- Create a test to check `fsnode_t` and `inode_t` are properly scavenged.
- Blocks inodes are never synchronized after a write operation. only the cached page are marked as dirty.
- Some fixes on design must be done for the `vfs_mkdev` and `vfs_mknod` procedures.
- Create a complete but generic test script to provide to cli_fs in order to test thoroughly a new file-system driver.
- Ensure tool-chain script is reliable
- `./disto.sh setup` must copy headers files before compiling libc.


## Big Epics

- __Raspberry PI handling__: requires an arm tool-chain. UART driver is easy enough and can be use to replace serial of the `i386` arch for kernel logging. However video and USB drivers are mandatory to make some real progress.
- __x86_64, long mode__: Write a port for long mode.
- __User__: Kora is not multi-user yet. _`@later`_
- __Memory swap__: Or any handling of a lack of memory pages. _`@later`_
- __IO Block layer__: We need to design the handling of write asynchronously. _`@later`_
- __Desktop__: The project is to run `/bin/login` at startup. It's run as system user and wait for user selection and authentication. The role is to create new instances of `bin/desktop` using the logon user. Both program need to exchange the ownership of all devices that constitute a _seat_ (`/dev/fb0`, `/dev/kdb`, `/dev/mse`...)

## Others

> __FS CLI__
> This is a tool made to be compiled with both kernel vfs module and fs drivers to be able to test both on an hosted environment using hard disc images.
>

> __NET CLI__
> This tool is build on the same principle as `FS CLI` but is made to test the network stack. One major gain is that it can simulate a full network of host with virtual link and Ethernet cards. However interaction with this tool is complex and yet quite limited.

> __SND__
> This tool is a proof-of-concept program used to transform and mix wave audio data for the future kernel sound system. It try to use host audio API, but I discover that playing audio facilities are really limited on current systems. My goal is to provide sound streaming through a pipe file.


## Documentation

- Overview

------------------------------

## Lgfx issues

- Set a background color for `gfx_clr_blend` and `gfx_bkgd_blend`.
- Make usage of source clip on `gfx_blit` and `gfx_blit_scale`.
- Resolve issue with frame invalidation and region invalidation.
- Remove mandatory usage of periodical timer
- Add new keyboard layout using external data file.
- Handle separation between framebuffer and event inputs.
- Handle multi pipe event inputs (for `/dev/kdb`, `/dev/mse` and service pipe...)
- Handle packaging build (for Debian `.deb` or windows `.zip` or others `.tar`)

## Desktop issues

- Create a message queue service for client application.
- Fix issue with `zlib` and test `freetype`.

------------------------------

# Milestones

### Version 0.1 of KoraOS

- Signal is supported
- FAT or EXT2 support write operations.
- TCP sockets client (`wget`)
- Graphical file browser application
- Graphical text editor application

### Version 1.0 of KoraOS

- Port of binutils, gcc, make, git, vim, python
- Full FAT12 / FAT16 / FAT32 / EXT2 drivers
- ATA drivers with DMA support
- VFS scavenging
- Task cleaning
- Fully working `ps` utilities
