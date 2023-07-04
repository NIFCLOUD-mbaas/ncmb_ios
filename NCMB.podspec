Pod::Spec.new do |s|
  s.name         = "NCMB"
  s.version      = "3.2.0"
  s.summary      = "NCMB is SDK for NIFCLOUD mobile backend."
  s.description  = <<-DESC
                   NCMB is SDK for NIFCLOUD mobile backend.
                   NIFCLOUD mobile backend function
                   * Data store
                   * Push Notification
                   * User Management
                   * SNS integration
                   * File store
                   DESC
  s.homepage     = "https://mbaas.nifcloud.com"
  s.license      = "Apache License, Version 2.0"
  s.author       = "FUJITSU CLOUD TECHNOLOGIES LIMITED"
  s.platform     = :ios
  s.source       = { :git => 'https://github.com/NIFCLOUD-mbaas/ncmb_ios.git', :tag => 'v3.2.0' }
  s.source_files  = "NCMB/**/*.{h,m,c}"
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration", "WebKit"
  s.requires_arc = true
end
