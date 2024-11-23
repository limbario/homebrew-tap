#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <scrcpy version>"
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
BUILD_DIR="build-macos-static"
DEPS_DIR="deps-static"

# Create directories
mkdir -p "$DEPS_DIR"
mkdir -p "$BUILD_DIR"

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

    make -j$(sysctl -n hw.ncpu)
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

    make -j$(sysctl -n hw.ncpu)
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
        --disable-video-x11 \
        --disable-video-wayland

    make -j$(sysctl -n hw.ncpu)
    make install
    cd ../..
}

download_prebuilt_server
# Build static dependencies
build_libusb
build_sdl
build_ffmpeg

# Configure scrcpy with static dependencies
PKG_CONFIG_PATH="$PWD/$DEPS_DIR/ffmpeg-install/lib/pkgconfig:$PWD/$DEPS_DIR/sdl-install/lib/pkgconfig:$PWD/$DEPS_DIR/libusb-install/lib/pkgconfig" \
CFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include -I$PWD/$DEPS_DIR/libusb-install/include/libusb-1.0" \
CPPFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include" \
LDFLAGS="-L$PWD/$DEPS_DIR/libusb-install/lib -framework Security -framework CoreFoundation -framework CoreGraphics -framework IOKit -framework AppKit -framework AudioToolbox -framework CoreAudio -framework Metal -framework AVFoundation -framework VideoToolbox" \
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
cp "$BUILD_DIR/app/scrcpy" "$DIST_DIR/scrcpy-darwin-v${VERSION}"

echo "Build complete! See $DIST_DIR"
ls -la "$DIST_DIR"
