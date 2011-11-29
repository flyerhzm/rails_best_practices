require "bundler"
Bundler.setup

require "rake"
require "rspec"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rails_best_practices/version"

task :build do
  system "gem build rails_best_practices.gemspec"
end

task :install => :build do
  system "sudo gem install rails_best_practices-#{RailsBestPractices::VERSION}.gem"
end

task :release => :build do
  puts "Tagging #{RailsBestPractices::VERSION}..."
  system "git tag -a #{RailsBestPractices::VERSION} -m 'Tagging #{RailsBestPractices::VERSION}'"
  puts "Pushing to Github..."
  system "git push --tags"
  puts "Pushing to rubygems.org..."
  system "gem push rails_best_practices-#{RailsBestPractices::VERSION}.gem"
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
task :test => :spec
