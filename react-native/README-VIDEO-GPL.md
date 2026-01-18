# @ameriles/ffmpeg-kit-react-native-video-gpl

FFmpeg Kit for React Native - Video GPL Optimized Build

## Features

- **Optimized for video transcoding**: Essential video codecs only
- **Small binary size**: ~20MB per platform (30-40% smaller than full-gpl)
- **Hardware acceleration**: VideoToolbox (iOS), MediaCodec (Android) - faster processing with lower battery consumption
- **Audio decoder support**: MP3, Vorbis, AAC, Opus, FLAC (no encoders)
- **No subtitle rendering**: fontconfig, freetype, libass excluded
- **GPL licensed codecs**: x264, x265, xvidcore included

## Installation

```bash
npm install github:ameriles/ffmpeg-kit#v1.2.0-video-gpl
# or
yarn add github:ameriles/ffmpeg-kit#v1.2.0-video-gpl
```

### Automatic Binary Download

Add a postinstall script to your React Native project's `package.json`:

```json
{
  "scripts": {
    "postinstall": "node node_modules/@ameriles/ffmpeg-kit-react-native-video-gpl/react-native/scripts/download-binaries.js || true"
  }
}
```

This will automatically download the native binaries (~30MB) from GitHub Releases on `npm install`.

### iOS Setup

Edit your `ios/Podfile` and add the following **before** `use_native_modules!`:

```ruby
pod 'ffmpeg-kit-react-native-video-gpl', :podspec => '../node_modules/@ameriles/ffmpeg-kit-react-native-video-gpl/react-native/ffmpeg-kit-react-native-video-gpl.podspec'
```

Then install pods:

```bash
cd ios && pod install
```

**Full Podfile example:**
```ruby
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

platform :ios, '12.1'

target 'YourApp' do
  config = use_native_modules!

  # Add this BEFORE use_native_modules! to avoid conflicts
  pod 'ffmpeg-kit-react-native-video-gpl', :podspec => '../node_modules/@ameriles/ffmpeg-kit-react-native-video-gpl/react-native/ffmpeg-kit-react-native-video-gpl.podspec'

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true
  )
end
```

### Android Setup

No additional configuration needed! The module automatically uses the local AAR with all video-gpl libraries included.

**Note:** Unlike the original ffmpeg-kit, you don't need to specify `ext.ffmpegKitPackage` in `android/build.gradle` because this build includes all video codecs by default.

## Usage

Same API as the original ffmpeg-kit-react-native:

```javascript
import { FFmpegKit } from '@ameriles/ffmpeg-kit-react-native-video-gpl';

// Transcode video, copy audio without re-encoding
await FFmpegKit.execute('-i input.mp4 -c:v libx264 -crf 23 -c:a copy output.mp4');
```

## Supported Codecs

### Video Encoders/Decoders
- H.264 (x264)
- H.265/HEVC (x265, kvazaar)
- VP8/VP9 (libvpx)
- AV1 (dav1d decoder)
- WebP (libwebp)
- XviD (xvidcore)

### Audio Decoders (native FFmpeg)
- MP3
- Vorbis
- AAC
- Opus
- FLAC

### Features
- Video stabilization (libvidstab)
- Colorspace conversion (zimg)
- Compression (snappy)
- Hardware acceleration (VideoToolbox on iOS, MediaCodec on Android)

## Hardware Acceleration

This build includes hardware acceleration support for faster video processing:

- **iOS**: VideoToolbox for H.264/H.265 encoding/decoding
- **Android**: MediaCodec for GPU-accelerated video processing

**Benefits:**
- ⚡ 2-5x faster encoding
- 🔋 Lower battery consumption
- 🌡️ Less device heat

For detailed usage examples and best practices, see [HARDWARE-ACCELERATION.md](./HARDWARE-ACCELERATION.md).

## What's NOT Included

- ❌ Audio encoders (lame, opus, shine, etc.)
- ❌ Subtitle rendering (libass, fontconfig, freetype)
- ❌ Legacy codecs (libtheora, libvorbis - use native instead)

## Binary Sizes

- iOS (arm64): 9.5 MB compressed (20 MB uncompressed)
- Android (arm-v7a + arm64-v8a): 20 MB

## Platform Support

- iOS: 12.1+, arm64 device only
- Android: API 24+ (Android 7.0+), arm-v7a and arm64-v8a

## License

GPL-3.0 (due to x264, x265, xvidcore)

## Credits

Based on [FFmpegKit](https://github.com/arthenica/ffmpeg-kit) by ARTHENICA.
