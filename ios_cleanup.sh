#!/bin/bash

# ios_cleanup.sh
# Script to clean up all iOS build artifacts and compiled binaries
# This will free up disk space after a successful build

echo "🧹 Cleaning up iOS build artifacts..."

# Remove prebuilt iOS binaries and frameworks
echo "  → Removing prebuilt iOS binaries..."
rm -rf prebuilt/apple-ios-arm64
rm -rf prebuilt/bundle-apple-framework-iphoneos
rm -rf prebuilt/bundle-apple-xcframework-ios

# Remove temporary build directories
echo "  → Removing temporary build files..."
rm -rf .tmp/ios*
rm -rf .tmp/apple*

# Remove build log (optional - comment out if you want to keep it)
# rm -f build.log

echo "✅ iOS cleanup complete!"
echo ""
echo "Disk space freed. You can now run a clean iOS build with:"
echo "  ./ios.sh --full --enable-gpl --disable-arm64-simulator --disable-arm64e --disable-i386 --disable-x86-64 --disable-x86-64-mac-catalyst --disable-arm64-mac-catalyst"
