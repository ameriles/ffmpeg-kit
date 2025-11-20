require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "ffmpeg-kit-react-native-local"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platform          = :ios
  s.requires_arc      = true
  s.static_framework  = true

  s.source       = { :path => '.' }

  s.dependency "React-Core"

  s.source_files      = 'ios/*.{h,m}'

  s.ios.deployment_target = '12.1'

  # Point to local XCFrameworks
  s.ios.vendored_frameworks = 'ios/Frameworks/*.xcframework'

  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64 i386',
    'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'armv7 armv7s arm64e x86_64 i386'
  }

  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64 i386',
    'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'armv7 armv7s arm64e x86_64 i386'
  }

end
