module.exports = {
  dependency: {
    platforms: {
      ios: {
        project: 'react-native/ios/FFmpegKitReactNativeModule.xcodeproj',
        podspecPath: 'react-native/ffmpeg-kit-react-native-video-gpl.podspec'
      },
      android: {
        sourceDir: 'react-native/android',
        packageImportPath: 'import com.arthenica.ffmpegkit.reactnative.FFmpegKitReactNativeModule;'
      }
    }
  }
};
