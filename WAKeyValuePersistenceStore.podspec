Pod::Spec.new do |s|
  s.name         = 'WAKeyValuePersistenceStore'
  s.version      = '1.0'
  s.author       = 'YuAo'
  s.summary      = 'A file based Key-Value persistence store for iOS.'
  s.homepage     = 'https://github.com/YuAo/WAKeyValuePersistenceStore'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.source       = { :git => "https://github.com/YuAo/WAKeyValuePersistenceStore.git", :tag => "1.0" }
  s.requires_arc = true
  s.subspec 'Core' do |ss|
    s.source_files = 'WAKeyValuePersistenceStore/*.{h,m}'
  end
  s.subspec 'Generics' do |ss|
    ss.source_files = 'WAKeyValuePersistenceStore/WAKeyValuePersistenceStore+Generics.swift'
  end
  s.platform     = :ios, '7.0'
end
