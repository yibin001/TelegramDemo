Pod::Spec.new do |spec|
  spec.name         = 'AsyncDisplayKit'
  spec.version      = '3.2.0'
  spec.license      =  { :type => 'Apache 2',  }
  spec.homepage     = 'http://texturegroup.org'
  spec.authors      = { 'Huy Nguyen' => 'hi@huynguyen.dev', 'Garrett Moon' => 'garrett@excitedpixel.com', 'Scott Goodson' => 'scottgoodson@gmail.com', 'Michael Schneider' => 'mischneider1@gmail.com', 'Adlai Holler' => 'adlai@icloud.com' }
  spec.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
  spec.source       = { :git => 'https://github.com/TextureGroup/Texture.git', :tag => spec.version.to_s }
  spec.module_name  = 'AsyncDisplayKit'
  spec.header_dir   = 'AsyncDisplayKit'
  
  spec.documentation_url = 'http://texturegroup.org/appledoc/'
  
  ios_deployment_target = '14.0'
  tvos_deployment_target = '14.0'
  spec.ios.deployment_target = ios_deployment_target
  spec.tvos.deployment_target = tvos_deployment_target
  
  spec.ios.deployment_target = ios_deployment_target
  spec.tvos.deployment_target = tvos_deployment_target
  spec.compiler_flags = '-fno-exceptions'
  spec.public_header_files = [
  'Source/PublicHeaders/AsyncDisplayKit/*.h',
  ]
  
  spec.source_files = [
  'Source/**/*.{h,mm}',
  
  # Most TextKit components are not public because the C++ content
  # in the headers will cause build errors when using
  # `use_frameworks!` on 0.39.0 & Swift 2.1.
  # See https://github.com/facebook/AsyncDisplayKit/issues/1153
  # 'Source/TextKit/*.h',
  ]
  
  # Include these by default for backwards compatibility.
  # This will change in 3.0.
  #  spec.default_subspecs = 'Core'
  
  spec.social_media_url = 'https://twitter.com/TextureiOS'
  spec.library = 'c++'
  spec.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
  
end
