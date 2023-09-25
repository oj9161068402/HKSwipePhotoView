# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

inhibit_all_warnings!

use_frameworks!

target 'HKSwipePhotoView' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for HKSwipePhotoView
  
  pod 'Then'
  pod 'SnapKit'
  # 资源管理
  pod 'R.swift'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end

