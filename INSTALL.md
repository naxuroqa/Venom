#Install Instructions

- [Installation](#installation)
    - [Linux](#linux)
    - [OS X](#osx)
    - [Windows](#windows)
- [FAQ](#faq)

<a name="installation" />
##Installation

<a name="linux" />
###Linux:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#linux).
Don't forget to install it after building it.

Additionally to the tox build dependencies, you will need:

```bash
valac (>=0.17)
cmake (>=2.6.0)
libgtk-3-dev (>=3.2)
libgee-0.8-dev
```

On Ubuntu:

```bash
apt-get install valac cmake libgtk-3-dev libgee-0.8-dev
```

Ubuntu <= 12.04 (Precise Pangolin) needs a ppa to get a newer version of valac
```bash
apt-add-repository ppa:vala-team/ppa
apt-get update
apt-get install valac cmake libgtk-3-dev libgee-0.8-dev
```

On Fedora:

```bash
yum install vala cmake gtk3-devel libgee-devel
```

On Arch Linux: (There is an [aur-package](https://aur.archlinux.org/packages/venom-git))

```bash
pacman -S vala cmake gtk3 libgee
```

After you installed the dependencies, clone, build and install venom:

```bash
git clone git://github.com/naxuroqa/Venom.git
cd Venom
mkdir build
cd build
cmake ..
make
sudo make install
```

<a name="osx" />
###OS X:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#os-x).

With Homebrew:
```bash
brew install vala cmake gtk+3 libgee git
git clone git://github.com/naxuroqa/Venom.git
cd Venom
mkdir build
cd build
cmake ..
make
sudo make install
```
<a name="windows" />
###Windows:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#windows).

After that you can either build vala and gtk3 from source or grab a binary bundle.

####Compiling from source
tbd

####Using a precompiled bundle
If you don't have cmake and git installed already:
* Download and install cmake from [here](http://www.cmake.org/cmake/resources/software.html).
* Download and install Git from [here](http://git-scm.com/download/win).

* Download and install a recent Vala+Gtk3 bundle from [here](http://www.tarnyko.net/dl/),
like [this one](http://www.tarnyko.net/repo/vala-0.20.1_\(GTK+-3.6.4\)\(TARNYKO\).exe).
Since the uninstaller will completely f*** you over, put it in a separate directory (e.g. C:\gtk3).
Add the included bin directory to your $PATH (C:\gtk3\bin).

* Download libgee-0.8 from [here](http://download.gnome.org/sources/libgee/0.8/libgee-0.8.7.tar.xz).
  Unzip it to your msys home directory. (e.g. C:\mingw\msys\1.0\home\$username).

Compile libgee:
```bash
cd libgee-0.8.7
./configure --prefix=/<yourprefix>
# if you have mingw mounted on /mingw, it should look like this:
# ./configure --prefix=/mingw
make
make install
```

####Compiling Venom

After this, you can begin compiling Venom:

```bash
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
```
<a name="faq" />
##FAQ
#### Cmake complaining about missing modules
If you are getting errors like these when running cmake
```bash
-- checking for module '<some_module>'
--   package '<some_module>' not found
CMake Error at /usr/share/cmake-2.8/Modules/FindPkgConfig.cmake:279 (message):
  A required package was not found
Call Stack (most recent call first):
  /usr/share/cmake-2.8/Modules/FindPkgConfig.cmake:333 (_pkg_check_modules_internal)
  CMakeLists.txt:30 (PKG_CHECK_MODULES)
```
then cmake can't find one or more dependencies needed to build Venom.

Make sure, that you have all dependencies mentioned above installed.
If you used a different prefix than ``/usr`` to install libtoxcore, you will need to tell it cmake here.
You do this by setting ``PKG_CONFIG_PATH=/<your_prefix>/lib/pkgconfig`` and running cmake again.

See also the solutions to [issue #4](https://github.com/naxuroqa/Venom/issues/4) and [issue #12](https://github.com/naxuroqa/Venom/issues/12)
#### Empty gui window when starting Venom
Happens when Venom can't find the required directories to load the .glade files containing the gui definitions.
Installing Venom will most likely fix that.

Venom also searches the working directory for those directories, so symlinking them to your working directory will also work.
The needed directories are: ``pixmaps``, ``theme`` and ``ui``.
