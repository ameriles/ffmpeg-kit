#!/bin/bash

# full_cleanup.sh
# Script to clean up ALL build artifacts (iOS + Android)
# Use this to completely reset the repository to a clean state

echo "🧹 Performing FULL cleanup (iOS + Android)..."
echo ""

# Clean Android
echo "📱 Cleaning Android artifacts..."
rm -rf prebuilt/android-arm
rm -rf prebuilt/android-arm64
rm -rf prebuilt/bundle-android-aar
rm -rf android/build
rm -rf android/.gradle
rm -rf android/ffmpeg-kit-android-lib/build
rm -rf android/ffmpeg-kit-android-lib/.cxx
rm -f android/jni/Application.mk

# Clean iOS
echo "🍎 Cleaning iOS artifacts..."
rm -rf prebuilt/apple-ios-arm64
rm -rf prebuilt/bundle-apple-framework-iphoneos
rm -rf prebuilt/bundle-apple-xcframework-ios

# Clean all temporary files
echo "🗑️  Cleaning temporary files..."
rm -rf .tmp

# Remove build log (optional - comment out if you want to keep it)
# rm -f build.log

echo ""
echo "✅ Full cleanup complete!"
echo ""
echo "Repository is now in a clean state. You can rebuild from scratch."
echo ""
echo "To measure iOS build time:"
echo "  time ./ios.sh --full --enable-gpl --disable-arm64-simulator --disable-arm64e --disable-i386 --disable-x86-64 --disable-x86-64-mac-catalyst --disable-arm64-mac-catalyst"
echo ""
echo "To measure Android build time:"
echo "  export ANDROID_SDK_ROOT=\"\$HOME/Library/Android/sdk\""
echo "  export ANDROID_NDK_ROOT=\"\$HOME/Library/Android/sdk/ndk/27.1.12297006\""
echo "  time ./android.sh --full --enable-gpl --disable-arm-v7a-neon --disable-x86 --disable-x86-64"
