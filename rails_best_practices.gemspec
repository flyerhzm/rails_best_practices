# -*- encoding: utf-8 -*-
require File.expand_path("../lib/rails_best_practices/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rails_best_practices"
  s.version     = RailsBestPractices::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Huang"]
  s.email       = ["flyerhzm@gmail.com"]
  s.homepage    = "http://rails-bestpractices.com"
  s.summary     = "a code metric tool for rails codes."
  s.description = "a code metric tool for rails codes, written in Ruby."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("ruby_parser", "~> 2.0.4")
  s.add_dependency("ruby-progressbar", "~> 0.0.9")
  s.add_dependency("colored", "~> 1.2")
  s.add_dependency("erubis", "~> 2.6.6")
  s.add_dependency("haml", "~> 3.0.18")
  s.add_dependency("i18n")
  s.add_dependency("activesupport")

  s.add_development_dependency("rspec", "~> 2.0.1")
  s.add_development_dependency("watchr", "~> 0.6")
  s.add_development_dependency("bundler", ">= 1.0.0")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.post_install_message = <<-POST_INSTALL_MESSAGE
#{"*" * 80}

  rails_best_practices is a code metric tool to check the quality of rails codes.

  I highly recommend you go through the Rails Best Practices website first.

      http://rails-bestpractices.com

  Enjoy!

      Richard Huang (flyerhzm@gmail.com)

#{"*" * 80}
  POST_INSTALL_MESSAGE
end
