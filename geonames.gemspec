lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'geonames'

SPEC = Gem::Specification.new do |s| 
  s.name = "geonames-with-proxy"
  s.version = Geonames::VERSION
  s.platform = Gem::Platform::RUBY 
  s.required_ruby_version     = '>= 1.8'
  s.required_rubygems_version = ">= 1.3"
  s.authors = ["Adam Wisniewski", "alex"]
  s.email = ["adamw@tbcn.ca", "alex@cloudware.it"]
  s.homepage = "http://www.tbcn.ca/ruby_geonames" 
  s.summary = "Ruby library for Geonames Web Services (http://www.geonames.org/export/)" 
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  
  s.files = Dir.glob("{lib,spec}/**/*") + %w(Rakefile README.rdoc)
  Dir.glob('**/*')
  
  s.require_path = "lib" 
end 
