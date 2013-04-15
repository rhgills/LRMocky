Pod::Spec.new do |s|
  s.name         = 'LRMocky'
  s.version      = '0.9.1x'
  s.summary      = 'A mock object library for Objective C, inspired by JMock 2.0.'
  s.license      = 'MIT'
  s.homepage     = 'http://github.com/lukeredpath/LRMocky'
  s.authors      = { 'Luke Redpath' => 'luke@lukeredpath.co.uk' }
  s.source       = { :git => 'https://github.com/rhgills/LRMocky/', :branch => 'v0.9.x' }
  s.source_files = 'Classes', 'Classes/LRMocky', 'Vendor'
end