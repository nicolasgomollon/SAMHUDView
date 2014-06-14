Pod::Spec.new do |spec|
  spec.name = 'SAMHUDView'
  spec.version = '0.2'
  spec.authors = {'Sam Soffes' => 'sam@soff.es', 'Nicolas Gomollon' => 'nicolas@techno-magic.com'}
  spec.homepage = 'https://github.com/soffes/SAMHUDView'
  spec.summary = 'Kind of okay HUD. WIP.'
  spec.source = {:git => 'https://github.com/soffes/SAMHUDView.git', :tag => "v#{spec.version}"}
  spec.license = { :type => 'MIT', :file => 'LICENSE' }

  spec.platform = :ios
  spec.requires_arc = true
  spec.frameworks = 'UIKit', 'CoreGraphics', 'QuartzCore'
  spec.source_files = 'SAMHUDView'
end
