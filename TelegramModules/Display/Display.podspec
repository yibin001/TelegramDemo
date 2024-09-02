Pod::Spec.new do |spec|
    spec.name         = 'Display'
    spec.version      = '2.2'
    spec.license      =  { :type => 'BSD' }
    spec.homepage     = 'http://asyncdisplaykit.org'
    spec.authors      = { 'Scott Goodson' => 'scottgoodson@gmail.com' }
    spec.summary      = 'Smooth asynchronous user interfaces for iOS apps.'
    spec.source       = { :git => 'https://github.com/facebook/AsyncDisplayKit.git', :tag => spec.version.to_s }
    spec.deprecated_in_favor_of = 'Texture'
  
    spec.documentation_url = 'http://asyncdisplaykit.org/appledoc/'
  
    spec.weak_frameworks = 'Photos','MapKit','AssetsLibrary'
    spec.requires_arc = true
  
    spec.public_header_files = [
          'Source/PublicHeaders/*.h'          
      ]
    spec.source_files = 
    [
          'Source/*.{swift}',
          'Source/Navigation/*.{swift}',
          'Source/Nodes/*.{swift}'
    ]

    spec.ios.deployment_target = '14.0'
    
    spec.dependency 'ObjCRuntimeUtils'
    spec.dependency 'UIKitRuntimeUtils'
    spec.dependency 'AppBundle'
    spec.dependency 'SwiftSignalKit'
    spec.dependency 'Markdown'
    spec.dependency 'AsyncDisplayKit'

  
  end
