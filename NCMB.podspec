Pod::Spec.new do |s|
  s.name         = "NCMB"
  s.version      = "2.4.3"
  s.summary      = "NCMB is SDK for NIF Cloud mobile backend."
  s.description  = <<-DESC
                   NCMB is SDK for NIF Cloud mobile backend.
                   NIF Cloud mobile backend function
                   * Data store
                   * Push Notification
                   * User Management
                   * SNS integration
                   * File store
                   DESC
  s.homepage     = "http://mb.cloud.nifty.com"
  s.license      = "Apache License, Version 2.0"
  s.author       = "FUJITSU CLOUD TECHNOLOGIES LIMITED"
  s.platform     = :ios, "5.1"
  s.source       = { :git => 'https://github.com/NIFCloud-mbaas/ncmb_ios.git', :tag => 'v2.4.3' }
  s.source_files  = "NCMB/**/*.{h,m,c}"
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration"
  s.requires_arc = true
end
