#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Usage: $0 <version> <output_dir>"
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

build_for_arch() {
    local ARCH="$1"
    local BUILD_DIR="build-linux-static-${ARCH}"
    local DEPS_DIR="deps-static-${ARCH}"
    local TOOLCHAIN=""
    local HOST=""
    local EXTRA_FLAGS=""

    if [ "$ARCH" = "arm64" ]; then
        TOOLCHAIN="aarch64-linux-gnu"
        HOST="aarch64-linux-gnu"
        EXTRA_FLAGS="--arch=aarch64"
    else
        TOOLCHAIN="x86_64-linux-gnu"
        HOST="x86_64-linux-gnu"
        EXTRA_FLAGS="--arch=x86_64"
    fi

    # Create directories
    mkdir -p "$DEPS_DIR"
    mkdir -p "$BUILD_DIR"

    # Build libusb statically
    build_libusb() {
        echo "Building libusb statically for ${ARCH}..."
        cd "$DEPS_DIR"

        if [ ! -f "libusb-$LIBUSB_VERSION.tar.bz2" ]; then
            curl -LO "https://github.com/libusb/libusb/releases/download/v$LIBUSB_VERSION/libusb-$LIBUSB_VERSION.tar.bz2"
        fi

        tar xf "libusb-$LIBUSB_VERSION.tar.bz2"
        cd "libusb-$LIBUSB_VERSION"

        ./configure \
            --host="$HOST" \
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
        echo "Building FFmpeg statically for ${ARCH}..."
        cd "$DEPS_DIR"

        if [ ! -f "ffmpeg-$FFMPEG_VERSION.tar.xz" ]; then
            curl -LO "https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz"
        fi

        tar xf "ffmpeg-$FFMPEG_VERSION.tar.xz"
        cd "ffmpeg-$FFMPEG_VERSION"

        ./configure \
            --cross-prefix="${TOOLCHAIN}-" \
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
            --disable-vulkan \
            --enable-pic \
            --enable-swresample \
            --pkg-config-flags="--static" \
            $EXTRA_FLAGS

        make -j$(nproc)
        make install
        cd ../..
    }

    # Build SDL2 statically
    build_sdl() {
        echo "Building SDL2 statically for ${ARCH}..."
        cd "$DEPS_DIR"
        curl -LO "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION.tar.gz"
        tar xf "SDL2-$SDL_VERSION.tar.gz"
        cd "SDL2-$SDL_VERSION"

        ./configure \
            --host="$HOST" \
            --prefix="$PWD/../../$DEPS_DIR/sdl-install" \
            --enable-static \
            --disable-shared \
            --enable-video-x11 \
            --enable-video-wayland

        make -j$(nproc)
        make install
        cd ../..
    }

    # Build dependencies
    build_libusb
    build_ffmpeg
    build_sdl

    # Configure scrcpy with static dependencies
    PKG_CONFIG_PATH="$PWD/$DEPS_DIR/ffmpeg-install/lib/pkgconfig:$PWD/$DEPS_DIR/sdl-install/lib/pkgconfig:$PWD/$DEPS_DIR/libusb-install/lib/pkgconfig" \
    CFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include -I$PWD/$DEPS_DIR/libusb-install/include/libusb-1.0" \
    CPPFLAGS="-I$PWD/$DEPS_DIR/libusb-install/include" \
    LDFLAGS="-L$PWD/$DEPS_DIR/libusb-install/lib -static-libgcc -static-libstdc++" \
    CC="${TOOLCHAIN}-gcc" \
    CXX="${TOOLCHAIN}-g++" \
    meson setup "$BUILD_DIR" \
        --cross-file="cross-${ARCH}.txt" \
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

    # Copy to dist directory
    mkdir -p "$DIST_DIR"
    cp "$BUILD_DIR/app/scrcpy" "$DIST_DIR/scrcpy-linux-${ARCH}"
}

# Download prebuilt server (only once)
download_prebuilt_server() {
    echo "Downloading prebuilt server..."
    mkdir -p prebuilt
    curl -L "https://github.com/Genymobile/scrcpy/releases/download/v${PREBUILT_SCRCPY_SERVER_VERSION}/scrcpy-server-v${PREBUILT_SCRCPY_SERVER_VERSION}" \
        -o "${PREBUILT_SCRCPY_SERVER_PATH}"
}

# Create cross-compilation configuration files
cat > cross-arm64.txt << 'EOF'
[binaries]
c = 'aarch64-linux-gnu-gcc'
cpp = 'aarch64-linux-gnu-g++'
ar = 'aarch64-linux-gnu-ar'
strip = 'aarch64-linux-gnu-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF

cat > cross-amd64.txt << 'EOF'
[binaries]
c = 'x86_64-linux-gnu-gcc'
cpp = 'x86_64-linux-gnu-g++'
ar = 'x86_64-linux-gnu-ar'
strip = 'x86_64-linux-gnu-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF

# Download server first
download_prebuilt_server

# Build for both architectures
build_for_arch "amd64"
build_for_arch "arm64"

# Copy server to dist directory
cp "${PREBUILT_SCRCPY_SERVER_PATH}" "$DIST_DIR/"

echo "Build complete! See $DIST_DIR"
ls -la "$DIST_DIR"
