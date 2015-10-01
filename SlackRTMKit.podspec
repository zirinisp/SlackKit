Pod::Spec.new do |s|
  s.name             = "SlackRTMKit"
  s.version          = "0.9.0"
  s.summary          = "a Swift wrapper of the Slack RTM API"
  s.homepage         = "https://github.com/pvzig/SlackRTMKit"
  s.license          = 'MIT'
  s.author           = { "Peter Zignego" => "peter@launchsoft.co" }
  s.source           = { :git => "https://github.com/pvzig/SlackRTMKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pvzig'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.source_files = 'SlackRTMKit/**/*'  
  s.frameworks = 'Foundation'
  s.dependency 'Starscream', '~> 1.0.1'
end
