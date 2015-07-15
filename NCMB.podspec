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
    cs.source_files  = "NCMB/Core/**/*.{h,m,c}"
    cs.public_header_files = "NCMB/Core/Public/*.h"
    cs.private_header_files = "NCMB/Core/Private/*.h"
  end

  s.subspec 'FacebookUtils' do |cs|
    cs.source_files  = "NCMB/FacebookUtils/**/*.{h,m,c}"
    cs.dependency "NCMB/Core"
    cs.public_header_files = "NCMB/FacebookUtils/Public/*.h"
    cs.private_header_files = "NCMB/FacebookUtils/Private/*.h"
  end

  s.subspec 'GoogleUtils' do |cs|
    cs.source_files  = "NCMB/GoogleUtils/**/*.{h,m,c}"
    cs.dependency "NCMB/Core"
    cs.public_header_files = "NCMB/GoogleUtils/Public/*.h"
    cs.private_header_files = "NCMB/GoogleUtils/Private/*.h"
  end

  s.source       = { :git => 'https://github.com/Rebirthble/ncmb_ios.git', :tag => "v#{s.version}" }
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration"
  s.requires_arc = true
end
