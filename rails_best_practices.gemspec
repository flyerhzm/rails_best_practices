# frozen_string_literal: true

require File.expand_path('../lib/rails_best_practices/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rails_best_practices'
  s.version     = RailsBestPractices::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Richard Huang']
  s.email       = ['flyerhzm@gmail.com']
  s.homepage    = 'http://rails-bestpractices.com'
  s.summary     = 'a code metric tool for rails codes.'
  s.description = 'a code metric tool for rails codes, written in Ruby.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.0'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency('activesupport')
  # TODO: add a dependency for Rails >= 3 ?
  s.add_dependency('code_analyzer', '>= 0.4.8')
  s.add_dependency('erubis')
  s.add_dependency('i18n')
  s.add_dependency('require_all', '~> 2.0')
  s.add_dependency('ruby-progressbar')
  s.add_dependency('json')

  s.add_development_dependency('rake', '< 11.0')
  s.add_development_dependency('rspec')
  s.add_development_dependency('haml')
  s.add_development_dependency('slim')
  s.add_development_dependency('bundler')
  s.add_development_dependency('awesome_print')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w[lib assets]

  s.post_install_message = <<-POST_INSTALL_MESSAGE
#{"*" * 80}

  rails_best_practices is a code metric tool to check the quality of rails codes.

  I highly recommend you browse the Rails Best Practices website first.

      http://rails-bestpractices.com

  Please also try our online service

      http://railsbp.com

  Enjoy!

      Richard Huang (flyerhzm@gmail.com)

#{"*" * 80}
  POST_INSTALL_MESSAGE
end
