require 'rspec/core/rake_task'
require 'rake/rdoctask'

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
end

Rake::RDocTask.new do |rdoc|
  require 'geonames'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "geonames #{Geonames::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec
