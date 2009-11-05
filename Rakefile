require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'jeweler'

desc 'Default: run unit tests.'
task :default => :spec

desc 'Generate documentation for the sitemap plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Bullet'
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
  gemspec.summary = "check rails files according to ihower's presentation 'rails best practices'"
  gemspec.description = "check rails files according to ihower's presentation 'rails best practices'"
  gemspec.email = "flyerhzm@gmail.com"
  gemspec.homepage = "http://github.com/flyerhzm/rails_best_practices"
  gemspec.authors = ["Richard Huang"]
end
Jeweler::GemcutterTasks.new
