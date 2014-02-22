Installation
============
- [Linux](#linux)
- [OS X](#os-x)
- [Windows](#windows)
- [FAQ](#faq)

Linux
=====

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#linux).
Don't forget to install it after building it.

Dependencies
------------

Additionally to the tox build dependencies, you will need:

| Package name     | Version   |
|------------------|-----------|
| valac            | >= 0.18.1 |
| cmake            | >=2.8.7   |
| libgtk-3-dev     | >=3.4     |
| libjson-glib-dev | >=0.14    |
| libsqlite3-dev   | >=3.7     |


Ubuntu >= 12.10 (Quantal Quetzal) / Linux Mint / Debian:

    apt-get install valac cmake libgtk-3-dev libjson-glib-dev libsqlite3-dev

Ubuntu 12.04 (Precise Pangolin): (needs a ppa to get a newer version of valac)

    apt-add-repository ppa:vala-team/ppa
    apt-get update
    apt-get install valac cmake libgtk-3-dev libjson-glib-dev libsqlite3-dev

Fedora:

    yum install vala cmake gtk3-devel json-glib-devel sqlite-devel

Arch Linux: (There is an [aur-package](https://aur.archlinux.org/packages/venom-git))

    pacman -S vala cmake gtk3 json-glib sqlite

Building and installing Venom
-----------------------------

After you installed the dependencies, clone, build and install venom:

    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    cmake ..
    make
    sudo make install

OS X
====

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#os-x).

With Homebrew
-------------

    brew tap Tox/tox
    brew install --HEAD libtoxcore
    brew install --HEAD venom

Windows
=======

The preferred way is to cross compile windows binaries from linux using the mingw-w64 toolchain.

Cross compile (mingw-w64)
-------------------------

###Dependencies
* Set up a mingw-w64 toolchain
* build ffmpeg (optionally for now)
* build libsodium
* build libtoxcore
* build gtk+-3.x
* build libjson-glib
* build libsqlite3

There is an [aur-package](https://aur.archlinux.org/packages/mingw-w64-venom-git) for arch linux, which automates the build process.

###Compiling Venom

    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    PKG_CONFIG_PATH=/usr/<yourcrosscompilerprefix>/lib/pkgconfig
    # you may have to adapt the mingw-toolchain.cmake file for your cross compiler prefix
    cmake -DCMAKE_C_FLAGS="-mwindows" \
          -DCOMPILER_PREFIX=<yourcrosscompilerprefix> \
          -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw-toolchain.cmake \
          -DCMAKE_BUILD_TYPE="Release" ..
    make
    sudo make install

FAQ
===
#### Cmake complaining about missing modules
If you are getting errors like these when running cmake

    -- checking for module '<some_module>'
    --   package '<some_module>' not found
    CMake Error at /usr/share/cmake-2.8/Modules/FindPkgConfig.cmake:279 (message):
      A required package was not found
    Call Stack (most recent call first):
      /usr/share/cmake-2.8/Modules/FindPkgConfig.cmake:333 (_pkg_check_modules_internal)
      CMakeLists.txt:30 (PKG_CHECK_MODULES)

then cmake can't find one or more dependencies needed to build Venom.

Make sure, that you have all dependencies mentioned above installed.
If you used a different prefix than ``/usr`` to install libtoxcore, you will need to tell it cmake here.
You do this by setting ``PKG_CONFIG_PATH=/<your_prefix>/lib/pkgconfig`` and running cmake again.

See also the solutions to [issue #4](https://github.com/naxuroqa/Venom/issues/4) and [issue #12](https://github.com/naxuroqa/Venom/issues/12)
