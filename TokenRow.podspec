Pod::Spec.new do |s|
  s.name             = "TokenRow"
  s.version          = "1.6.0"
  s.summary          = "An Eureka row that allows the user to select options into a token view."
  s.homepage         = "https://github.com/EurekaCommunity/TokenRow"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Xmartlabs SRL" => "swift@xmartlabs.com" }
  s.source           = { git: "https://github.com/EurekaCommunity/TokenRow.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/EurekaCommunity'
  s.ios.deployment_target = '11.0'
  s.requires_arc = true
  s.ios.source_files = 'TokenRow/Sources/**/*.{swift}'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Eureka', '~> 5.4'
  s.dependency 'CLTokenInputView', '~> 2.3'
  s.swift_version = "5.0"
end
