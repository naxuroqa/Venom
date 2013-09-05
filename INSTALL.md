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

This is currently difficult, since there are no official gtk3 packages for windows (yet).
There is a [branch](https://github.com/naxuroqa/Venom/tree/gtk2) which is using gtk2 and builds on windows, 
but it is not up to date.
