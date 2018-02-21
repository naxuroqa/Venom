# Installation

## Linux

### Install from flathub (recommended)

Released versions will be available on flathub

### Building from source

#### Step 1: Install tox

Either download a [binary package](https://tox.chat/download.html) or [compile from source](https://github.com/TokTok/c-toxcore/blob/master/INSTALL.md).

If you are lucky there may be a package in the repository of your distribution.

#### Step 2: Install build dependencies

You will need quite recent versions of these libraries.

```
gcc OR clang
libgtk3-dev
libjson-glib-dev
libsoup2.4-dev
libsqlite3-dev
meson
valac
```

#### Step 3: Install venom

```
# Create and initialize build directory
meson build

# cd to build directory
cd build

# Build
ninja

# Install
sudo ninja install
```
