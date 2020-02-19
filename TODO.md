
# Note about the Kora distriubtion scripts

Those scripts, like every other kora packages are not yet stable. Never assume
that a script can be replace by another even after a simple source update.


## Makefile

I pretty confidente that i have -- finally -- manage to get a stable Makefile
script. Sript which is generic, easly readable, maitenable and
extensible.

Those file are replicated on each repository, which is not good, but I didn't wanted a build script that depend on anything more.

Hopefuly this repository contains a list of common files to copy on each
package. Modificatio to those files should be proposed on this repository
and propagted afterward (using a simple `./disto.sh update`).


## Commons sources

All `kora-*` repositories share a certains amount of files that are
replicated around each packages.
Replication in IT is bad, really bad !
Sadly I didn't yet manage to find a good way of centralize those data.
I want most of my base repository to be completly portable and standalone,
which means they can't depends on exotic dependancies.

I try to regroup all those sources as headers and place them on
`include/kora/`. However those are still working with some source files (like
`bbtree.c`).
I also require some file to wrap usefull function not available on all plateforms like cthreads spec or `dirent.h` for windows.


## Develop under visual studio

Visula studio is not the tool of choice when developping an OS. However it's
an handy tool to make development work easly and with minimum configuration
on windows plateform.
I presanaly need a windows for interoperability with much other system and
this is what I used at work. Beeing able to test code under visual studio stay
a good nive to have.

However as the prime focus is to develop tools that work for a UNIX like
environment, most change an building will stay on Makefile and visual studio
files are often out-dated. I still didn't manage to find a reliable way to
keep track of those change so it explain why some repository have a `vs/`
folder appreaing and disapearing often on repositories.





