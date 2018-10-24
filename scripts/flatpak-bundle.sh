#! /bin/sh
set -e

flatpak-builder --stop-at=venom --repo=repo app com.github.naxuroqa.venom.yml
flatpak build app meson --prefix=/app _build
flatpak build app ninja -C _build install
flatpak-builder --finish-only --repo=repo app com.github.naxuroqa.venom.yml
flatpak build-bundle repo com.github.naxuroqa.venom.x86_64.flatpak --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo com.github.naxuroqa.venom
