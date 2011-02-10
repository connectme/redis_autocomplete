require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "redis_autocomplete"
  gem.homepage = "http://github.com/connectme/redis_autocomplete"
  gem.license = "MIT"
  gem.summary = %Q{Use Redis for fast autocomplete suggestions}
  gem.description = %Q{Use Redis for fast autocomplete suggestions. Just add words to it and ask it to make suggestions given a search prefix. Originally packaged for http://connect.me.}
  gem.email = "joe@simple10.com"
  gem.authors = ["Joe Johnston (simple10)", "Ben Woosley (Empact)", "Salvatore Sanfilippo (antirez)"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "redis_autocomplete #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
