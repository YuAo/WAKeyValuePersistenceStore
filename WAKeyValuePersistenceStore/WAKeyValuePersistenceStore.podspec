Pod::Spec.new do |s|
  s.name         = 'WAKeyValuePersistenceStore'
  s.version      = '1.0'
  s.author       = 'YuAo'
  s.requires_arc = true
  s.subspec 'Core' do |ss|
    s.source_files = '**/*.{h,m}'
  end
  s.subspec 'Generics' do |ss|
    ss.source_files = 'WAKeyValuePersistenceStore+Generics.swift'
  end
  s.ios.deployment_target = '7.0'
end
