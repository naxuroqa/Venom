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
    libgee-0.8-dev \
    meson \
    valac \
    wget

RUN rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/TokTok/c-toxcore/archive/v0.2.2.tar.gz" && \
  tar -xzf v0.2.2.tar.gz && \
  cd c-toxcore-0.2.2 && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr && \
  make && \
  make install && \
  cd ..
