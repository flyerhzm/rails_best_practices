require "bundler"
require "bundler/gem_tasks"

Bundler.setup

require "rake"
require "rspec"
require "rspec/core/rake_task"
require 'rubocop/rake_task'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rails_best_practices/version"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

RuboCop::RakeTask.new

task :default => [:spec, :rubocop]
task :test => :spec
