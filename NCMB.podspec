Pod::Spec.new do |s|
  s.name         = "NCMB"
  s.version      = "2.2.1"
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
  s.subspec 'Core' do |cs|
    s.source_files  = "NCMB/Core/**/*.{h,m,c}"
  end
  s.subspec 'FacebookUtils' do |cs|
    s.source_files  = "NCMB/FacebookUtils/**/*.{h,m,c}"
  end
  s.subspec 'GoogleUtils' do |cs|
    s.source_files  = "NCMB/GoogleUtils/**/*.{h,m,c}"
  end
  s.source       = { :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git', :tag => 'v2.2.1' }
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration"
  s.requires_arc = true
end
