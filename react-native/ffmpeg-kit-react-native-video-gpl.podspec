require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "ffmpeg-kit-react-native-video-gpl"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platform          = :ios, "12.1"
  s.requires_arc      = true
  s.static_framework  = true

  s.source       = { :git => "https://github.com/ameriles/ffmpeg-kit.git", :tag => "v#{s.version}-video-gpl" }

  s.source_files = "ios/**/*.{h,m}"

  s.dependency "React-Core"

  # Use local frameworks downloaded by postinstall script
  s.vendored_frameworks = [
    "ios/ffmpegkit.framework",
    "ios/libavcodec.framework",
    "ios/libavdevice.framework",
    "ios/libavfilter.framework",
    "ios/libavformat.framework",
    "ios/libavutil.framework",
    "ios/libswresample.framework",
    "ios/libswscale.framework"
  ]

  s.frameworks = "AudioToolbox", "VideoToolbox", "CoreMedia"
  s.libraries = "z", "bz2", "c++"
end
