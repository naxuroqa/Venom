#Install Instructions

- [Installation](#installation)
    - [Linux](#linux)
    - [OS X](#osx)
    - [Windows](#windows)

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
libgee-dev (1.0)
```

On Ubuntu:

```bash
apt-get install valac cmake libgtk-3-dev libgee-dev
```

Ubuntu <= 12.04 (Precise Pangolin) needs a ppa to get a newer version of valac
```bash
apt-add-repository ppa:vala-team/ppa
apt-get update
apt-get install valac cmake libgtk-3-dev libgee-dev
```

On Fedora:

```bash
yum install vala cmake gtk3-devel libgee06-devel
```

On Arch Linux: (There is an [aur-package](https://aur.archlinux.org/packages/venom-git))

```bash
pacman -S vala cmake gtk3 libgee06
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

To be done

<a name="windows" />
###Windows:

Follow ProjectTox-Core [installation instructions](https://github.com/irungentoo/ProjectTox-Core/blob/master/INSTALL.md#windows).

After that you can either build vala and gtk3 from source or grab a binary bundle.

####Compiling from source
tbd

####Using a precompiled bundle

* Download and install a recent Vala+Gtk3 bundle from [here](http://www.tarnyko.net/dl/),
like [this one](http://www.tarnyko.net/repo/vala-0.20.1_\(GTK+-3.6.4\)\(TARNYKO\).exe).
* Download and install cmake from [here](http://www.cmake.org/cmake/resources/software.html).
* Download libgee06 from [here](https://vala-win32.googlecode.com/files/libgee-0.6.1.zip) and unzip it to your msys root.

####Compiling Venom

After this, you can begin compiling Venom:

```bash
git clone git://github.com/naxuroqa/Venom.git
cd Venom
mkdir build
cd build
cmake ..
make
```
