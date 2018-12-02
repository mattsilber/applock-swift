Pod::Spec.new do |s|
  s.name = 'SwiftyAppLock'
  s.version = '1.1.1'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.summary = 'The Swift/iOS implementation of AppLock'
  s.homepage = 'http://github.com/mattsilber/AppLock-swift'
  s.author = { 'matt' => 'matt@guardanis.com' }
  s.requires_arc = true
  s.source = { 
    :git => 'git@github.com:mattsilber/AppLock-swift.git', 
    :tag => s.version  
  }
  s.source_files = 'SwiftyAppLock/**/*.swift'
  s.resource_bundles = {
    'SwiftyAppLock' => ['SwiftyAppLock/**/*.{xib,xcassets}']
  }
  s.ios.deployment_target = '8.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
end 
