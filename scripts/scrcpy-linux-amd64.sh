#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <scrcpy version> <output_dir>"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Usage: $0 <scrcpy version> <output_dir>"
    exit 1
fi

VERSION="$1"
DIST_DIR="$2"

# Configuration
PREBUILT_SCRCPY_SERVER_VERSION="${VERSION}"
PREBUILT_SCRCPY_SERVER_PATH="prebuilt/scrcpy-server-v${PREBUILT_SCRCPY_SERVER_VERSION}"
FFMPEG_VERSION="7.1"
SDL_VERSION="2.30.9"
LIBUSB_VERSION="1.0.27"
BUILD_DIR="build-linux-static"
DEPS_DIR="deps-static"

# Create directories
mkdir -p "$DEPS_DIR"
mkdir -p "$BUILD_DIR"

install_dependencies() {
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        curl ca-certificates \
        nasm \
        build-essential \
        pkg-config \
        meson \
        ninja-build \
        libx11-dev \
        libxrandr-dev \
        libxinerama-dev \
        libxcursor-dev \
        libwayland-dev \
        libxkbcommon-dev \
        libpulse-dev \
        libasound2-dev \
        libpipewire-0.3-dev \
        libwayland-dev \
        libdecor-0-dev
}

download_prebuilt_server() {
    echo "Downloading prebuilt server..."
    mkdir -p prebuilt
    curl -L "https://github.com/Genymobile/scrcpy/releases/download/v${PREBUILT_SCRCPY_SERVER_VERSION}/scrcpy-server-v${PREBUILT_SCRCPY_SERVER_VERSION}" \
        -o "${PREBUILT_SCRCPY_SERVER_PATH}"
}

# Build libusb statically
build_libusb() {
    echo "Building libusb statically..."
    cd "$DEPS_DIR"

    if [ ! -f "libusb-$LIBUSB_VERSION.tar.bz2" ]; then
        curl -LO "https://github.com/libusb/libusb/releases/download/v$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2"
    fi

    tar xf "libusb-$LIBUSB_VERSION.tar.bz2"
    cd "libusb-$LIBUSB_VERSION"

    ./configure \
        --prefix="$PWD/../../$DEPS_DIR/libusb-install" \
        --enable-static \
        --disable-shared \
        --disable-udev

    make -j$(nproc)
    make install
    cd ../..
}

# Build FFmpeg statically
build_ffmpeg() {
    echo "Building FFmpeg statically..."
    cd "$DEPS_DIR"

    if [ ! -f "ffmpeg-$FFMPEG_VERSION.tar.xz" ]; then
        curl -LO "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz"
    fi

    tar xf "ffmpeg-$FFMPEG_VERSION.tar.xz"
    cd "ffmpeg-$FFMPEG_VERSION"

    ./configure \
        --prefix="$PWD/../../$DEPS_DIR/ffmpeg-install" \
        --enable-static \
        --disable-shared \
        --disable-programs \
        --disable-doc \
        --disable-everything \
        --enable-decoder=h264 \
        --enable-decoder=hevc \
        --enable-decoder=av1 \
        --enable-decoder=pcm_s16le \
        --enable-decoder=opus \
        --enable-decoder=aac \
        --enable-decoder=flac \
        --enable-decoder=png \
        --enable-protocol=file \
        --enable-demuxer=image2 \
        --enable-parser=png \
        --enable-muxer=matroska \
        --enable-muxer=mp4 \
        --enable-muxer=opus \
        --enable-muxer=flac \
        --enable-muxer=wav \
        --enable-pic \
        --enable-swresample \
        --enable-small \
        --pkg-config-flags="--static"

    make -j$(nproc)
    make install
    cd ../..
}

# Build SDL2 statically
build_sdl() {
    echo "Building SDL2 statically..."
    cd "$DEPS_DIR"
    curl -LO "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION.tar.gz"
    tar xf "SDL2-$SDL_VERSION.tar.gz"
    cd "SDL2-$SDL_VERSION"

    ./configure \
        --prefix="$PWD/../../$DEPS_DIR/sdl-install" \
        --enable-static \
        --disable-shared \
        --enable-video-x11 \
        --enable-video-wayland \
        --enable-pulseaudio \
        --enable-pulseaudio-shared=no \
        --enable-alsa \
        --enable-alsa-shared=no \
        --enable-pipewire \
        --enable-pipewire-shared=no

    make -j$(nproc)
    make install
    cd ../..
}

install_dependencies
download_prebuilt_server
# Build static dependencies
build_libusb
build_sdl
build_ffmpeg

# Configure scrcpy with static dependencies
PKG_CONFIG_PATH="$PWD/$DEPS_DIR/ffmpeg-install/lib/pkgconfig:$PWD/$DEPS_DIR/sdl-install/lib/pkgconfig:$PWD/$DEPS_DIR/libusb-install/lib/pkgconfig" \
CFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include -I$PWD/$DEPS_DIR/libusb-install/include/libusb-1.0" \
CPPFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include" \
LDFLAGS="-L$PWD/$DEPS_DIR/libusb-install/lib -static-libgcc -static-libstdc++" \
meson setup "$BUILD_DIR" \
    --buildtype=release \
    --strip \
    -Db_staticpic=true \
    -Db_lto=true \
    -Dportable=true \
    -Dcompile_server=false \
    -Dprebuilt_server="${PREBUILT_SCRCPY_SERVER_PATH}" \
    -Dc_args="-I$PWD/$DEPS_DIR/libusb-install/include" \
    --wipe

# Build scrcpy
ninja -C "$BUILD_DIR"

# Create distributable package
mkdir -p "$DIST_DIR"
cp "$BUILD_DIR/app/scrcpy" "$DIST_DIR/scrcpy-linux-v${VERSION}"

echo "Build complete! See $DIST_DIR"
ls -la "$DIST_DIR"
