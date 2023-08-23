#
# Be sure to run `pod lib lint sqlite.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'sqlite3'
  s.version          = '0.0.1a'
  s.summary          = 'SQLite'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SQLite built for iOS and iOS simulators.
                       DESC

  s.homepage         = 'https://github.com/totalpaveinc/sqlite'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Norman Breau' => 'norman@totalpave.com' }
  s.source           = { :git => 'https://github.com/totalpaveinc/sqlite-bin.git', :tag => 'v' + s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.vendored_frameworks = 'dist/ios/sqlite3.xcframework'

  #s.source_files = 'sqlite/Classes/**/*'
  
  # s.resource_bundles = {
  #   'sqlite' => ['sqlite/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
