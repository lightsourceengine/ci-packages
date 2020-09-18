#!/bin/sh
set -e

SDL_VERSION="SDL2-2.0.12"
SDL_SRC_ROOT="/tmp/${SDL_VERSION}"
ARCH="$1"

if [ ! -d "${SDL_SRC_ROOT}" ]; then
  wget -qO- https://www.libsdl.org/release/${SDL_VERSION}.tar.gz | tar xz -C /tmp
fi

if [ "${ARCH}" = "" ]; then
  echo "Argument must be a user defined arch (armv7l, etc)"
  exit 1
fi

# TODO: should x11 be included?
VIDEO_DRIVER_FLAGS="--enable-video-rpi --enable-video-kmsdrm"

cd "${SDL_SRC_ROOT}"
rm -rf "${SDL_SRC_ROOT}/build"
./configure ${VIDEO_DRIVER_FLAGS} --disable-video-wayland --disable-video-x11 --disable-video-opengl --disable-video-vulkan
make -j2
cd -

TARGET="${SDL_VERSION}-${ARCH}-pi"
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

