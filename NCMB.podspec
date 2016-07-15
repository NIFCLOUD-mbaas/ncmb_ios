Pod::Spec.new do |s|
  s.name         = "NCMB"
  s.version      = "2.3.3"
  s.summary      = "NCMB is SDK for NIFTY Cloud mobile backend."
  s.description  = <<-DESC
                   NCMB is SDK for NIFTY Cloud mobile backend.
                   NIFTY Cloud mobile backend function
                   * Data store
                   * Push Notification
                   * User Management
                   * SNS integration
                   * File store
                   DESC
  s.homepage     = "http://mb.cloud.nifty.com"
  s.license      = "Apache License, Version 2.0"
  s.author             = "NIFTY Corporation"
  s.platform     = :ios, "5.1"
  s.source       = { :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git', :tag => 'v2.3.3' }
  s.source_files  = "NCMB/**/*.{h,m,c}"
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration"
  s.requires_arc = true
end
