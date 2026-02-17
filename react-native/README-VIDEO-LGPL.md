# @ameriles/ffmpeg-kit-react-native-video-lgpl

FFmpeg Kit for React Native - Video LGPL Optimized Build (no GPL libraries)

## Features

- **Optimized for video transcoding**: Essential video codecs only
- **No GPL libraries**: Fully LGPL-3.0 compliant
- **Small binary size**: ~20MB per platform
- **Hardware acceleration**: VideoToolbox (iOS), MediaCodec (Android) - faster processing with lower battery consumption
- **H.264 encoding**: openh264 (software) + VideoToolbox/MediaCodec (hardware)
- **H.265 encoding**: kvazaar (software, LGPL) + VideoToolbox/MediaCodec (hardware)
- **Audio decoder support**: MP3, Vorbis, AAC, Opus, FLAC (no encoders)
- **No subtitle rendering**: fontconfig, freetype, libass excluded

## Installation

```bash
npm install github:ameriles/ffmpeg-kit#v2.0.0-video-lgpl
# or
yarn add github:ameriles/ffmpeg-kit#v2.0.0-video-lgpl
```

### Automatic Binary Download

Add a postinstall script to your React Native project's `package.json`:

```json
{
  "scripts": {
    "postinstall": "node node_modules/@ameriles/ffmpeg-kit-react-native-video-lgpl/react-native/scripts/download-binaries.js || true"
  }
}
```

This will automatically download the native binaries (~30MB) from GitHub Releases on `npm install`.

### iOS Setup

Edit your `ios/Podfile` and add the following **before** `use_native_modules!`:

```ruby
pod 'ffmpeg-kit-react-native-video-lgpl', :podspec => '../node_modules/@ameriles/ffmpeg-kit-react-native-video-lgpl/react-native/ffmpeg-kit-react-native-video-lgpl.podspec'
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
  pod 'ffmpeg-kit-react-native-video-lgpl', :podspec => '../node_modules/@ameriles/ffmpeg-kit-react-native-video-lgpl/react-native/ffmpeg-kit-react-native-video-lgpl.podspec'

  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true
  )
end
```

### Android Setup

No additional configuration needed! The module automatically uses the local AAR with all video-lgpl libraries included.

**Note:** Unlike the original ffmpeg-kit, you don't need to specify `ext.ffmpegKitPackage` in `android/build.gradle` because this build includes all video codecs by default.

## Usage

Same API as the original ffmpeg-kit-react-native:

```javascript
import { FFmpegKit } from '@ameriles/ffmpeg-kit-react-native-video-lgpl';

// Transcode video using openh264 software encoder
await FFmpegKit.execute('-i input.mp4 -c:v libopenh264 -c:a copy output.mp4');

// Or use hardware encoder (iOS VideoToolbox)
await FFmpegKit.execute('-i input.mp4 -c:v h264_videotoolbox -b:v 2M -c:a copy output.mp4');
```

## Supported Codecs

### Video Encoders/Decoders
- H.264 (openh264 software encoder, BSD)
- H.264 (VideoToolbox/MediaCodec hardware encoder)
- H.265/HEVC (kvazaar software encoder, LGPL)
- H.265/HEVC (VideoToolbox/MediaCodec hardware encoder)
- VP8/VP9 (libvpx)
- AV1 (dav1d decoder)
- WebP (libwebp)

### Audio Decoders (native FFmpeg)
- MP3
- Vorbis
- AAC
- Opus
- FLAC

### Features
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

- ❌ GPL libraries (x264, x265, xvidcore, libvidstab)
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

LGPL-3.0 (no GPL libraries included)

## Credits

Based on [FFmpegKit](https://github.com/arthenica/ffmpeg-kit) by ARTHENICA.
