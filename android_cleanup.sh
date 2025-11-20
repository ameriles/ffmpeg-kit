#!/bin/bash

# android_cleanup.sh
# Script to clean up all Android build artifacts and compiled binaries
# This will free up disk space after a successful build

echo "🧹 Cleaning up Android build artifacts..."

# Remove prebuilt Android binaries and libraries
echo "  → Removing prebuilt Android binaries..."
rm -rf prebuilt/android-arm
rm -rf prebuilt/android-arm64
rm -rf prebuilt/bundle-android-aar

# Remove Android Gradle build directories
echo "  → Removing Android Gradle build artifacts..."
rm -rf android/build
rm -rf android/.gradle
rm -rf android/ffmpeg-kit-android-lib/build
rm -rf android/ffmpeg-kit-android-lib/.cxx

# Remove Android JNI generated files
echo "  → Removing JNI generated files..."
rm -f android/jni/Application.mk

# Remove temporary build directories
echo "  → Removing temporary build files..."
rm -rf .tmp/android*

# Remove build log (optional - comment out if you want to keep it)
# rm -f build.log

echo "✅ Android cleanup complete!"
echo ""
echo "Disk space freed. You can now run a clean Android build with:"
echo "  export ANDROID_SDK_ROOT=\"\$HOME/Library/Android/sdk\""
echo "  export ANDROID_NDK_ROOT=\"\$HOME/Library/Android/sdk/ndk/27.1.12297006\""
echo "  ./android.sh --full --enable-gpl --disable-arm-v7a-neon --disable-x86 --disable-x86-64"
