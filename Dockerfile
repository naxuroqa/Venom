FROM debian:sid

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y \
    build-essential \
    cmake \
    libgtk-3-dev \
    libjson-glib-dev \
    libopus-dev \
    libsodium-dev \
    libsoup2.4-dev \
    libsqlite3-dev \
    libvpx-dev \
    meson \
    valac \
    wget

RUN rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/TokTok/c-toxcore/releases/download/v0.1.11/c-toxcore-0.1.11.tar.gz" && \
  tar -xzf c-toxcore-0.1.11.tar.gz && \
  cd c-toxcore-0.1.11 && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_NTOX=off&& \
  make && \
  make install && \
  cd .. && \
  rm -rf c-toxcore-0.1.11
