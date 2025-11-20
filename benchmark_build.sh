#!/bin/bash

# benchmark_build.sh
# Script to measure the complete build time for both iOS and Android
# This will give you accurate timing for your M3 MacBook Pro 💪

echo "🚀 Starting ffmpeg-kit full build benchmark..."
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
./ios.sh --full --enable-gpl \
  --disable-arm64-simulator \
  --disable-arm64e \
  --disable-i386 \
  --disable-x86-64 \
  --disable-x86-64-mac-catalyst \
  --disable-arm64-mac-catalyst

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
./android.sh --full --enable-gpl \
  --disable-arm-v7a-neon \
  --disable-x86 \
  --disable-x86-64

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
echo "iOS build:     ${IOS_MINUTES}m ${IOS_SECONDS}s"
echo "Android build: ${ANDROID_MINUTES}m ${ANDROID_SECONDS}s"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total time:    ${TOTAL_MINUTES}m ${TOTAL_SECONDS}s"
echo ""
echo "Machine: $(sysctl -n machdep.cpu.brand_string)"
echo "Cores: $(sysctl -n hw.ncpu)"
echo ""
echo "🎉 All builds completed successfully!"
