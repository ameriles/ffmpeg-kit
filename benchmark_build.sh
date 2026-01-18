#!/bin/bash

# benchmark_build.sh
# Script to measure the complete build time for both iOS and Android
# This will give you accurate timing for your M3 MacBook Pro 💪

# Parse arguments
BUILD_TYPE="video"  # default to video-gpl

while [[ $# -gt 0 ]]; do
    case $1 in
        --full)
            BUILD_TYPE="full"
            shift
            ;;
        --video)
            BUILD_TYPE="video"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--full|--video]"
            echo "  --full:  Build full-gpl variant (all codecs, all libraries)"
            echo "  --video: Build video-gpl variant (video codecs + GPL, default)"
            exit 1
            ;;
    esac
done

if [ "$BUILD_TYPE" = "full" ]; then
    echo "🚀 Starting ffmpeg-kit FULL-GPL build benchmark..."
else
    echo "🚀 Starting ffmpeg-kit VIDEO-GPL build benchmark..."
fi

echo "Platform: $(uname -m)"
echo "Date: $(date)"
echo ""

# Check if we need to clean first
if [ -d "prebuilt" ] && [ "$(ls -A prebuilt 2>/dev/null)" ]; then
    echo "⚠️  Previous build artifacts detected."
    read -p "Do you want to clean before benchmarking? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./full_cleanup.sh
        echo ""
    fi
fi

# iOS Build
echo "=========================================="
echo "📱 Starting iOS build..."
echo "=========================================="
echo ""

IOS_START=$(date +%s)

if [ "$BUILD_TYPE" = "video" ]; then
    # video-gpl: solo codecs de video esenciales (sin subtítulos ni texto)
    ./ios.sh --enable-gpl \
      --enable-dav1d \
      --enable-kvazaar \
      --enable-libvpx \
      --enable-libwebp \
      --enable-snappy \
      --enable-libvidstab \
      --enable-x264 \
      --enable-x265 \
      --enable-xvidcore \
      --enable-zimg \
      --enable-ios-videotoolbox \
      --disable-arm64-simulator \
      --disable-arm64e \
      --disable-i386 \
      --disable-x86-64 \
      --disable-x86-64-mac-catalyst \
      --disable-arm64-mac-catalyst
else
    # full-gpl: todas las librerías
    ./ios.sh --full --enable-gpl \
      --disable-arm64-simulator \
      --disable-arm64e \
      --disable-i386 \
      --disable-x86-64 \
      --disable-x86-64-mac-catalyst \
      --disable-arm64-mac-catalyst
fi

IOS_END=$(date +%s)
IOS_DURATION=$((IOS_END - IOS_START))
IOS_MINUTES=$((IOS_DURATION / 60))
IOS_SECONDS=$((IOS_DURATION % 60))

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ iOS build completed successfully!"
    echo "⏱️  Time: ${IOS_MINUTES}m ${IOS_SECONDS}s"
else
    echo ""
    echo "❌ iOS build failed!"
    echo "⏱️  Time before failure: ${IOS_MINUTES}m ${IOS_SECONDS}s"
    exit 1
fi

echo ""
echo ""

# Android Build
echo "=========================================="
echo "🤖 Starting Android build..."
echo "=========================================="
echo ""

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_NDK_ROOT="$HOME/Library/Android/sdk/ndk/27.1.12297006"

ANDROID_START=$(date +%s)

if [ "$BUILD_TYPE" = "video" ]; then
    # video-gpl: solo codecs de video esenciales (sin subtítulos ni texto)
    ./android.sh --enable-gpl \
      --enable-dav1d \
      --enable-kvazaar \
      --enable-libvpx \
      --enable-libwebp \
      --enable-snappy \
      --enable-libvidstab \
      --enable-x264 \
      --enable-x265 \
      --enable-xvidcore \
      --enable-zimg \
      --enable-android-media-codec \
      --disable-arm-v7a-neon \
      --disable-x86 \
      --disable-x86-64
else
    # full-gpl: todas las librerías
    ./android.sh --full --enable-gpl \
      --disable-arm-v7a-neon \
      --disable-x86 \
      --disable-x86-64
fi

ANDROID_END=$(date +%s)
ANDROID_DURATION=$((ANDROID_END - ANDROID_START))
ANDROID_MINUTES=$((ANDROID_DURATION / 60))
ANDROID_SECONDS=$((ANDROID_DURATION % 60))

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Android build completed successfully!"
    echo "⏱️  Time: ${ANDROID_MINUTES}m ${ANDROID_SECONDS}s"
else
    echo ""
    echo "❌ Android build failed!"
    echo "⏱️  Time before failure: ${ANDROID_MINUTES}m ${ANDROID_SECONDS}s"
    exit 1
fi

# Calculate total time
TOTAL_DURATION=$((IOS_DURATION + ANDROID_DURATION))
TOTAL_MINUTES=$((TOTAL_DURATION / 60))
TOTAL_SECONDS=$((TOTAL_DURATION % 60))

echo ""
echo "=========================================="
echo "📊 BUILD BENCHMARK RESULTS"
echo "=========================================="
echo ""
if [ "$BUILD_TYPE" = "video" ]; then
    echo "Build type:    VIDEO-GPL"
else
    echo "Build type:    FULL-GPL"
fi
echo "iOS build:     ${IOS_MINUTES}m ${IOS_SECONDS}s"
echo "Android build: ${ANDROID_MINUTES}m ${ANDROID_SECONDS}s"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total time:    ${TOTAL_MINUTES}m ${TOTAL_SECONDS}s"
echo ""
echo "Machine: $(sysctl -n machdep.cpu.brand_string)"
echo "Cores: $(sysctl -n hw.ncpu)"
echo ""
echo "🎉 All builds completed successfully!"

# Package release artifacts
echo ""
echo "=========================================="
echo "📦 PACKAGING RELEASE ARTIFACTS"
echo "=========================================="

IOS_BUNDLE_DIR="prebuilt/bundle-apple-framework-ios"
ANDROID_BUNDLE_DIR="prebuilt/bundle-android-aar"

IOS_ARCHIVE="prebuilt/ffmpeg-kit-video-gpl-ios.tar.gz"
ANDROID_ARCHIVE="prebuilt/ffmpeg-kit-video-gpl-android.zip"

if [ ! -d "${IOS_BUNDLE_DIR}" ]; then
    echo "❌ iOS bundle not found at ${IOS_BUNDLE_DIR}"
    echo "   Ensure ios.sh completed successfully and frameworks were created."
    exit 1
fi

if [ ! -d "${ANDROID_BUNDLE_DIR}" ]; then
    echo "❌ Android bundle not found at ${ANDROID_BUNDLE_DIR}"
    echo "   Ensure android.sh completed successfully and the AAR was created."
    exit 1
fi

echo "Creating iOS archive: ${IOS_ARCHIVE}"
rm -f "${IOS_ARCHIVE}"
(cd prebuilt && tar -czf "$(basename "${IOS_ARCHIVE}")" "$(basename "${IOS_BUNDLE_DIR}")")

echo "Creating Android archive: ${ANDROID_ARCHIVE}"
rm -f "${ANDROID_ARCHIVE}"
(cd prebuilt && zip -r "$(basename "${ANDROID_ARCHIVE}")" "$(basename "${ANDROID_BUNDLE_DIR}")" >/dev/null)

echo "✅ Release artifacts created:"
echo " - ${IOS_ARCHIVE}"
echo " - ${ANDROID_ARCHIVE}"
