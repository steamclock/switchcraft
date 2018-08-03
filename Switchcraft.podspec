Pod::Spec.new do |s|
  s.name             = 'Switchcraft'
  s.version          = '1.1.0'
  s.summary          = 'Drop and go endpoint selector written in Swift.'
  s.homepage         = 'https://github.com/steamclock/Switchcraft'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brendan@steamclock.com' => 'brendan@steamclock.com' }
  s.source           = { :git => 'https://github.com/steamclock/Switchcraft.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.3'
  s.resource_bundles = {
  'Switchcraft' => ['Switchcraft/*/Assets.xcassets']
  }
  s.source_files = 'Switchcraft/Classes/**/*'
  s.swift_version = '3.2'
end
