
# Kora OS

 No source, juste building checking and helping scripts.

 Create the distribution


## Kora distribution components

### Kernel

 The kernel is the main project...

### Drivers

 The kernel feature are still limited if we don't ahve driver or module to
 extends its capacity and communicate with external devices.

 Organisation by group.

 Linux choose to include all open source drivers into their main repo, which
 represent the large majority of the code base and hide the kernel simplicity behind all those complex features.

 However one single repo for each drivers look completly ridiculous as some basic drivers are made of a single files. They are by definition not portable code at all, however I tried to make drivers development the most
 easy possbile for non-driver programmer. The API - badly documented yet - is light and quite easy - at least that the goal I aimed for.

 Drivers packages:

  - `kora-file-system`: Common file system for storage disks
  - `kora-fs-extra`: Uncommon file system for specific usage (future)
  - `kora-drivers-pc`: Pack for all drivers specific to the PC architecture.
    note that this package will exist into several declinaison.
    When targeting an architecture, we defined a triplet made of `arch-vendor-os`, all supported vendor part will have it's own repository.
  - `kora-drivers-misc`: Micallenous drivers. Those regroup drivers that doesn't have its own category, like in-dev `vbox` driver (VirtualBox).

 > Question about `kora-network-ip` ? May be network stack might be taken out of the rest of the kernel code as it doesn't imapct it's behaviour and only use a small API.


### The standard C implemenation

 gcc is too big, to complex
 musl is linux specific which is quite sad.
 newlib is meant to be portable but is quitte big and doesn't cover everything, beside optimization is not great at all.

### OpenLibM

 Not my work, I choose OpenLibM from JuliaLang Team as it's quitte simpe to build, isolate from C library quite portable with good level of optimization.

### Lgfx

 The most basic and portable way of creating UI facilities.

 It's can work standalone, but if the environment allow it. It get codex to manipulate png or jpeg images or more...

 It also have everything to support various keyboard layout effort-less.


### Gum

 For `Graphic Ui Module`

 Complex desktop GUI will be nightmare if build over lgfx so gum provide a new layer to draw widgets to build complex windows.
 It's means to be portable, as such we have several disto suported:
  - lgfx-freetype   - Kora, linux, windows
  - lgfx-cairo      - Kora, (complex on linux and windows)
  _ x11-cairo       - Linux specific
  - win32           - Windows specific



### Utils

 Utils are used as command line utilities. It contains the most usefull command to do basic operation on the system.

 On the future we might replace this by buzybox which is a lot more complete.
 It will depend on the effort require to get descent tooling for Kora.

### Krish

 `KoRa Interactive SHell`

 Krish is a windows program that create a terminal with the most basic CLI features.
 It's the first program that will allow to operate the system.


### Desktop

 This solution is made of several important tool from which the most important are `/bin/logon` and `/bin/desktop`. Both are GUI program meant to be full and blocking screen (in the term that you can'not go without autorization to other screen like the dektop of another user).

 The logon program is started as the first program once the kernel is up.
 The role is to load system settings and users informations.
 It will then start some services for the system or allowed users and display a basic screen for login and minor configurations.

 Once a login get authenticated on logon program, a desktop instance is started for the user. It will load preferences and allow to include other windows. It will play the role of windows manager for the time of the user session.

### Pakage Manager

 Command `pkg` with the whole suite.


### What's next

 Well if everything is working right it will be already quite good!
 But it means application development will already be much easier. To pursue on this way, I will bring support for main lanaguages. In order of utility over port difficulty I think it will be : C++, Python, C#, Js and Java.

 I may pursue a bit application dev to get a good integration with the OS, but as this stage it will be best to make port of community apps easier.

 Apps that should be delivered as part of the distribution:

 - FileBrowser / Finder (search a cool name)
 - Basic text editor
 - Internet browser (big challenge - the decisive part for this will be include the `HTML nightmare layout` into library gum, js come omly after but with js popularity it became simple as porting V8 or alike)

 - PictureApp (Some ideas here... don't like to share too soon)
 - Office app (Not a fancy one but juste basic view-editing of regular office files - docx, odt, xlsx, pptx, pdf - If it's binary I dont care! - Need more go port libre office)

