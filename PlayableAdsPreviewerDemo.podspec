Pod::Spec.new do |s|
  s.name             = 'PlayableAdsPreviewerDemo'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PlayableAdsPreviewer.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/JiaDingYi/PlayableAdsPreviewerDemo.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wzy2010416033@163.com' => 'wzy2010416033@163.com' }
  s.source           = { :git => 'https://github.com/JiaDingYi/PlayableAdsPreviewerDemo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PlayableAdsPreviewer/QRCodeReaderViewController/**/*'
  
  # s.resource_bundles = {
  #   'PlayableAdsPreviewer' => ['PlayableAdsPreviewer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit','AVFoundation'
  s.dependency 'TSMessages'
end
