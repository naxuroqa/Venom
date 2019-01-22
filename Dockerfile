FROM ubuntu:18.04

RUN \
  apt update && \
  apt install -y software-properties-common gnupg && \
  add-apt-repository ppa:vala-team/ppa -y

RUN \
  apt-get update && \
  apt-get install -y \
    clang \
    cmake \
    libconfig-dev \
    libgtest-dev \
    libopus-dev \
    libsodium-dev \
    libvpx-dev \
    pkg-config \
    libgee-0.8-dev \
    libgspell-1-dev \
    libgtk-3-dev \
    libjson-glib-dev \
    libsoup2.4-dev \
    libsqlcipher-dev \
    libcanberra-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    valac \
    python3-pip \
    wget

RUN pip3 install meson ninja

RUN rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/TokTok/c-toxcore/archive/v0.2.9.tar.gz" && \
  tar -xzf v0.2.9.tar.gz && \
  cd c-toxcore-0.2.9 && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr && \
  make && \
  make install && \
  cd ..
