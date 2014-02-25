require 'rubygems'
require 'bundler'
require "rspec/core/rake_task"
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
  gem.name = "storyboardlint"
  gem.homepage = "https://github.com/jfahrenkrug/StoryboardLint"
  gem.license = "MIT"
  gem.summary = %Q{A lint tool for UIStoryboards to find wrong classes and wrong storyboard/segue/reuse identifiers}
  gem.description = %Q{It's a pain to to keep identifier strings in your UIStoryboard and in your source code in sync. This tool helps you to do just that.}
  gem.email = "johannes@springenwerk.com"
  gem.authors = ["Johannes Fahrenkrug"]
  
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

RSpec::Core::RakeTask.new

task :test => :spec
task :default => :spec
