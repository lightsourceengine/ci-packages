#!/bin/sh

# Builds a platform specific SDL package.
#
# Usage: ./build-sdl.sh [SDLVideoDriverName] [targetArch]
#
# Intended to be run on a target system (this is not a cross compiling script). The script creates a bundle in the
# current working directory. The bundle contains SDL2 headers and a precompiled SDL2 shared object.
#
# When running on a raspberry pi (or a debian target), the following dependencies should be installed via apt:
# - sudo apt build-dep libsdl2             # for building sdl2 and the rpi video driver
# - sudo apt install libdrm-dev libgbm-dev # for kmsdrm video driver

set -e

SDL_VERSION="SDL2-2.0.12"
SDL_SRC_ROOT="/tmp/${SDL_VERSION}"
ARCH="$2"

if [ ! -d "${SDL_SRC_ROOT}" ]; then
  wget -qO- https://www.libsdl.org/release/${SDL_VERSION}.tar.gz | tar xz -C /tmp
fi

if [ "${ARCH}" = "" ]; then
  echo "Second argument must be a user defined arch (armv7l, etc)"
  exit 1
fi

if [ "$1" = "rpi" ]; then
  VIDEO_DRIVER="$1"
elif [ "$1" = "kmsdrm" ]; then
  VIDEO_DRIVER="$1"
else
  echo "First argument must be and SDL video driver (rpi or kmsdrm)"
  exit 1
fi

cd "${SDL_SRC_ROOT}"
rm -rf "${SDL_SRC_ROOT}/build"
./configure --enable-video-${VIDEO_DRIVER} --disable-video-wayland --disable-video-x11 --disable-video-opengl --disable-video-vulkan
make -j2
cd -

TARGET="${SDL_VERSION}-${ARCH}-${VIDEO_DRIVER}"
TARGET_ROOT="./${TARGET}"

if [ -d "${TARGET_ROOT}" ]; then
  rm -r "${TARGET_ROOT}"/*
fi

mkdir -p "${TARGET_ROOT}/include/SDL2"
mkdir -p "${TARGET_ROOT}/lib"

cp -L "${SDL_SRC_ROOT}/build/.libs/libSDL2-2.0.so.0" "${TARGET_ROOT}/lib"
cp -r "${SDL_SRC_ROOT}/include/"* "${TARGET_ROOT}/include/SDL2"
strip "${TARGET_ROOT}/lib/libSDL2-2.0.so.0"

tar -czf "${TARGET}.tar.gz" ${TARGET}

