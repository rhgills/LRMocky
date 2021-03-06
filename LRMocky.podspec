Pod::Spec.new do |s|
  s.name         = 'LRMocky'
  s.version      = '1.0'
  s.license      = 'MIT'
  s.summary      = 'A mock object library for Objective C, inspired by JMock 2.0'
  s.homepage     = 'http://github.com/lukeredpath/LRMocky'
  s.authors      = { 'Luke Redpath' => 'luke@lukeredpath.co.uk' }
  s.source       = { :git => 'https://github.com/lukeredpath/LRMocky.git' }
  s.requires_arc = true
  
  # exclude files that are not ARC compatible
  source_files = FileList['Classes/**/*.{h,m}'].exclude(/LRMockyAutomation/)
  source_files.exclude(/NSInvocation\+(BlockArguments|OCMAdditions).m/)
  s.source_files = source_files
  
  s.public_header_files = FileList['Classes/**/*.h'].exclude(/LRMockyAutomation/)
  
  # create a sub-spec just for the non-ARC files
   s.subspec 'no-arc' do |sp|
     sp.source_files = FileList['Classes/LRMocky/Categories/NSInvocation+{BlockArguments,OCMAdditions}.m']
     sp.requires_arc = false
   end

  # platform targets
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  
  # dependencies
  s.dependency 'OCHamcrest', '1.9'
end
