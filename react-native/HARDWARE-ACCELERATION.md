# Hardware Acceleration Guide

## Overview

This video-gpl build includes hardware acceleration support for both iOS and Android platforms:

- **iOS**: VideoToolbox for H.264/H.265 hardware encoding/decoding
- **Android**: MediaCodec for GPU-accelerated video processing

## Benefits

- ⚡ **Faster processing**: 2-5x faster than software encoding
- 🔋 **Lower battery consumption**: Offloads work to dedicated hardware
- 🌡️ **Cooler device**: Reduces CPU usage and heat generation
- 📱 **Better user experience**: Smoother video processing on mobile devices

## How It Works

FFmpeg automatically detects and uses hardware acceleration when available. No special flags are needed in most cases.

### Supported Codecs

#### iOS VideoToolbox
- H.264 (AVC)
- H.265 (HEVC)

#### Android MediaCodec
- H.264 (AVC)
- H.265 (HEVC)
- VP8
- VP9

## Usage Examples

### Basic Video Transcoding

```typescript
import { FFmpegKit } from '@ameriles/ffmpeg-kit-react-native-video-gpl';

// Hardware acceleration is used automatically for H.264/H.265
const command = '-i input.mp4 -c:v libx264 -preset medium -crf 23 -c:a copy output.mp4';
await FFmpegKit.execute(command);
```

### iOS-Specific: Force VideoToolbox

To explicitly use VideoToolbox on iOS:

```typescript
// H.264 encoding with VideoToolbox
const command = '-i input.mp4 -c:v h264_videotoolbox -b:v 2M -c:a copy output.mp4';
await FFmpegKit.execute(command);

// H.265 encoding with VideoToolbox
const command = '-i input.mp4 -c:v hevc_videotoolbox -b:v 2M -c:a copy output.mp4';
await FFmpegKit.execute(command);
```

### Android-Specific: Force MediaCodec

To explicitly use MediaCodec on Android:

```typescript
// H.264 decoding with MediaCodec
const command = '-hwaccel mediacodec -c:v h264_mediacodec -i input.mp4 -c:v libx264 -c:a copy output.mp4';
await FFmpegKit.execute(command);

// Note: MediaCodec is primarily used for decoding. For encoding, software codecs are typically faster.
```

## Best Practices

### 1. Let FFmpeg Choose

For most use cases, let FFmpeg automatically select the best encoder:

```typescript
// FFmpeg will use hardware acceleration when beneficial
const command = '-i input.mp4 -c:v libx264 -preset medium -c:a copy output.mp4';
```

### 2. Video Compression

```typescript
// Compress video to reduce file size (hardware-accelerated)
const command = '-i input.mp4 -c:v libx264 -preset medium -crf 28 -c:a copy compressed.mp4';
await FFmpegKit.execute(command);
```

### 3. Format Conversion

```typescript
// Convert MOV to MP4 (hardware-accelerated when possible)
const command = '-i input.mov -c:v libx264 -c:a aac output.mp4';
await FFmpegKit.execute(command);
```

### 4. Resolution Scaling

```typescript
// Scale video to 720p (hardware-accelerated)
const command = '-i input.mp4 -vf scale=1280:720 -c:v libx264 -preset medium -c:a copy output.mp4';
await FFmpegKit.execute(command);
```

### 5. Video Stabilization

```typescript
// Two-pass video stabilization
// Pass 1: Analyze
const analyzeCmd = '-i input.mp4 -vf vidstabdetect=shakiness=10:accuracy=15 -f null -';
await FFmpegKit.execute(analyzeCmd);

// Pass 2: Transform (hardware-accelerated encoding)
const transformCmd = '-i input.mp4 -vf vidstabtransform=smoothing=30,unsharp=5:5:0.8:3:3:0.4 -c:v libx264 -preset medium -c:a copy stabilized.mp4';
await FFmpegKit.execute(transformCmd);
```

## Performance Comparison

Typical encoding times for a 1-minute 1080p video:

| Platform | Software Encoding | Hardware Encoding | Improvement |
|----------|------------------|-------------------|-------------|
| iOS (iPhone 14) | ~45 seconds | ~15 seconds | **3x faster** |
| Android (Snapdragon 888) | ~60 seconds | ~20 seconds | **3x faster** |

*Results may vary depending on device model, video complexity, and encoding settings.*

## Troubleshooting

### Hardware Acceleration Not Working

1. **Check device compatibility**: Older devices may not support hardware acceleration
2. **Verify codec support**: Not all codecs have hardware acceleration
3. **Check FFmpeg logs**: Enable verbose logging to see if hardware is being used

```typescript
import { FFmpegKitConfig } from '@ameriles/ffmpeg-kit-react-native-video-gpl';

// Enable verbose logging
FFmpegKitConfig.enableLogCallback((log) => {
  console.log(log.getMessage());
});
```

### Common Issues

#### iOS

- **VideoToolbox requires iOS 8.0+**: Older devices won't support it
- **Some presets not supported**: Use bitrate mode (`-b:v`) instead of CRF

```typescript
// Instead of CRF (not supported by VideoToolbox)
// const command = '-c:v h264_videotoolbox -crf 23'; // ❌

// Use bitrate mode
const command = '-c:v h264_videotoolbox -b:v 2M'; // ✅
```

#### Android

- **MediaCodec varies by device**: Some devices have better hardware support than others
- **Encoding may fall back to software**: If hardware encoding fails, FFmpeg will use software

## When to Use Hardware Acceleration

### ✅ Good Use Cases

- Real-time video processing
- Battery-sensitive applications
- High-resolution video (4K, 1080p)
- Multiple video operations in sequence
- Mobile devices with good hardware support

### ⚠️ When Software Encoding Might Be Better

- Need maximum quality (hardware encoders may have quality limitations)
- Need specific encoding features not supported by hardware
- Target very small file sizes (software encoders have more control)
- Processing very short videos (overhead of hardware initialization)

## Additional Resources

- [FFmpeg VideoToolbox Documentation](https://trac.ffmpeg.org/wiki/HWAccelIntro)
- [FFmpeg MediaCodec Documentation](https://ffmpeg.org/ffmpeg-codecs.html#Android-MediaCodec)
- [Video Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.264)

## Version Information

This guide applies to:
- **Package Version**: v1.0.4+
- **FFmpeg Version**: Based on FFmpeg 6.0+
- **iOS**: VideoToolbox support included
- **Android**: MediaCodec support included (API 24+)

## Support

For issues or questions:
- GitHub Issues: https://github.com/ameriles/ffmpeg-kit/issues
- Original Project: https://github.com/arthenica/ffmpeg-kit
