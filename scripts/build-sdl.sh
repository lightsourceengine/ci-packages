#!/bin/sh
set -e

SDL_VERSION="SDL2-2.0.12"
SDL_SRC_ROOT="/tmp/${SDL_VERSION}"
ARCH="$1"

if [ ! -d "${SDL_SRC_ROOT}" ]; then
  wget -qO- https://www.libsdl.org/release/${SDL_VERSION}.tar.gz | tar xz -C /tmp
fi

case "${ARCH}" in
  "armv6l")
    export CFLAGS="-march=armv6zk"
    export LDFLAGS="-march=armv6zk"
    ;;
  "armv7l")
    export CFLAGS="-march=armv7-a -mfpu=neon"
    export LDFLAGS="-march=armv7-a -mfpu=neon"
    ;;
  *)
    echo "Argument must be an architecture of [armv6l, armv7l]"
    exit 1
    ;;
esac

VIDEO_DRIVER_FLAGS="--enable-video-rpi --enable-video-kmsdrm --enable-video-x11"

cd "${SDL_SRC_ROOT}"
rm -rf "${SDL_SRC_ROOT}/build"
./configure ${VIDEO_DRIVER_FLAGS} --disable-video-wayland --disable-video-dummy --disable-video-opengl --disable-video-vulkan
make ${MAKE_FLAGS:--j2}
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
