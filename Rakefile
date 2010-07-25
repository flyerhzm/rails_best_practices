require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'jeweler'

desc 'Default: run unit tests.'
task :default => :spec

desc 'Generate documentation for the rails_best_practices plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'rails_best_practices'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "rails_best_practices"
  gemspec.summary = "a code metric tool for rails codes."
  gemspec.description = "a code metric tool for rails codes."
  gemspec.email = "flyerhzm@gmail.com"
  gemspec.homepage = "http://rails-bestpractices.com"
  gemspec.authors = ["Richard Huang"]
  gemspec.add_dependency 'ruby_parser', '>= 2.0.4'
  gemspec.add_dependency 'ruby2ruby', '>= 1.2.4'
end
Jeweler::GemcutterTasks.new
