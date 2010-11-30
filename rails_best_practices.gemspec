# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "rails_best_practices/version"

Gem::Specification.new do |s|
  s.name        = "rails_best_practices"
  s.version     = RailsBestPractices::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Huang"]
  s.email       = ["flyerhzm@gmail.com"]
  s.homepage    = "http://rails-bestpractices.com"
  s.summary     = "a code metric tool for rails codes."
  s.description = "a code metric tool for rails codes, written in Ruby."
  s.default_executable = "rails_best_practices"
  s.executables = ["rails_best_practices"]

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("ruby_parser", ["~> 2.0.4"])
  s.add_dependency("progressbar", ["~> 0.9.0"])
  s.add_dependency("colored", ["~> 1.2"])
  s.add_dependency("i18n")
  s.add_dependency("activesupport")

  s.add_development_dependency("rspec", ["~> 2.0.1"])
  s.add_development_dependency("haml", ["~> 3.0.18"])
  s.add_development_dependency("watchr", ["~> 0.6"])

  s.extra_rdoc_files = ["MIT_LICENSE", "README.textile"]
  s.files        = Dir.glob("lib/**/*") + %w(rails_best_practices.yml MIT_LICENSE README.textile)
  s.require_path = 'lib'
end
