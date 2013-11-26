#Installation
- Building and installing
    - [Linux](#linux)
    - [OS X](#osx)
    - [Windows](#windows)
- [FAQ](#faq)



#Linux:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#linux).
Don't forget to install it after building it.

## Dependencies

Additionally to the tox build dependencies, you will need:

    valac (>=0.17)
    cmake (>=2.6.0)
    libgtk-3-dev (>=3.2)
    libgee-0.8-dev

Ubuntu / Linux Mint / Debian:

    apt-get install valac cmake libgtk-3-dev libgee-0.8-dev

Ubuntu <= 12.04 (Precise Pangolin) needs a ppa to get a newer version of valac

    apt-add-repository ppa:vala-team/ppa
    apt-get update
    apt-get install valac cmake libgtk-3-dev libgee-0.8-dev

Fedora:

    yum install vala cmake gtk3-devel libgee-devel

Arch Linux: (There is an [aur-package](https://aur.archlinux.org/packages/venom-git))

    pacman -S vala cmake gtk3 libgee

## Building and installing Venom

After you installed the dependencies, clone, build and install venom:

    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    cmake ..
    make
    sudo make install

#OS X:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#os-x).

##With Homebrew:

    brew install vala cmake gtk+3 libgee git
    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    cmake ..
    make
    sudo make install

#Windows:

The preferred way is to cross compile windows binaries from linux using the mingw-w64 toolchain.

##Cross compile (mingw-w64)

###Dependencies
* Set up a mingw-w64 toolchain
* build ffmpeg (optionally for now)
* build libsodium
* build libtoxcore
* build gtk+ 3.x
* build libgee

There is a package for arch linux doing exactly that: https://aur.archlinux.org/packages/mingw-w64-venom-git

###Compiling Venom

    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    PKG_CONFIG_PATH=/usr/<yourcrosscompilerprefix>/lib/pkgconfig
    cmake -DCMAKE_C_FLAGS="-mwindows" \
          -DCOMPILER_PREFIX=<yourcrosscompilerprefix> \
          -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw-toolchain.cmake \
          -DCMAKE_BUILD_TYPE="Release" ..
    make
    sudo make install

##On Windows (mingw-w64)

* If you don't have cmake and git installed already:
 *  Download and install cmake from [here](http://www.cmake.org/cmake/resources/software.html).
 *  Download and install Git from [here](http://git-scm.com/download/win).

###Dependencies

* Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#windows).
* Either grab a gtk+ 3.x bundle from [here](http://www.gtk.org/download/win32.php) (32-bit only) or compile it from source.
* Download libgee-0.8 from [here](http://ftp.gnome.org/pub/GNOME/sources/libgee/0.12).

Compile libgee:

    cd libgee-0.12.0
    ./configure --prefix=/<yourprefix>
    # if you have mingw mounted on /mingw, it should look like this:
    # ./configure --prefix=/mingw
    make
    make install

###Compiling Venom

After this, you can begin compiling Venom:

    git clone git://github.com/naxuroqa/Venom.git
    cd Venom
    mkdir build
    cd build
    cmake -G "MinGW Makefiles" ..
    # Ignore cmake complaining about sh.exe being in PATH for now,
    # just run it again and it will work
    # 
    # you can hide the console window by passing this to the c-compiler
    # cmake -G "MinGW Makefiles" -DCMAKE_C_FLAGS="-mwindows" ..
    # 
    # If you are getting pkg-config errors, provide pkg-config with the correct path
    # and run cmake again
    # PKG_CONFIG_PATH=/<yourprefix>/lib/pkgconfig cmake ..
    # so if you installed tox to /mingw, use
    # PKG_CONFIG_PATH=/mingw/lib/pkgconfig cmake ..
    # 
    # (finally) build it
    mingw32-make

#FAQ
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
