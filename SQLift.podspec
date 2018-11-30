#
# Be sure to run `pod lib lint SQLift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                    = 'SQLift'
  s.version                 = '0.1.3'
  s.summary                 = 'Wrapper library for sqlite3 in Swift'
  s.swift_version           = '4.0'
  s.ios.deployment_target   = '11.2'
  s.library                 = 'sqlite3'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Wrapper library for sqlite3 in Swift used to facilitate the use of sqlite library without the need of objc and bridging headers
                       DESC

  s.homepage         = 'https://github.com/dimitrebogdanov/SQLift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dimitrebogdanov' => 'dimitre_7@hotmail.com' }
  s.source           = { :git => 'https://github.com/dimitrebogdanov/SQLift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SQLift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SQLift' => ['SQLift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'sqlite3', 'libsqlite3'
  # s.dependency 'AFNetworking', '~> 2.3'
end
