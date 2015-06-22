Pod::Spec.new do |s|
  s.name         = 'WAKeyValuePersistenceStore'
  s.version      = '1.0'
  s.author       = 'YuAo'
  s.summary      = 'A file based Key-Value persistence store for iOS.'
  s.homepage     = 'https://github.com/YuAo/WAKeyValuePersistenceStore'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.source       = { :git => "https://github.com/YuAo/WAKeyValuePersistenceStore.git", :tag => "1.1" }
  s.requires_arc = true
  s.platform     = :ios, '7.0'
  s.subspec 'Core' do |ss|
    ss.source_files = 'WAKeyValuePersistenceStore/**/*.{h,m}'
  end
  s.subspec 'Generics' do |ss|
    ss.source_files = 'WAKeyValuePersistenceStore/WAKeyValuePersistenceStore+Generics.swift'
    ss.platform     = :ios, '8.0'
    ss.dependency 'WAKeyValuePersistenceStore/Core'
  end
  s.default_subspec = 'Core'
end
