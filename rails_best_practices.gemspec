# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_best_practices/version'

Gem::Specification.new do |spec|
  spec.name        = 'rails_best_practices'
  spec.version     = RailsBestPractices::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Richard Huang']
  spec.email       = ['flyerhzm@gmail.com']
  spec.homepage    = 'http://rails-bestpractices.com'
  spec.summary     = 'a code metric tool for rails codes.'
  spec.description = 'a code metric tool for rails codes, written in Ruby.'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.3.0'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.add_runtime_dependency('activesupport')
  spec.add_runtime_dependency('code_analyzer', '~> 0.5.5')
  spec.add_runtime_dependency('erubis')
  spec.add_runtime_dependency('i18n')
  spec.add_runtime_dependency('json')
  spec.add_runtime_dependency('require_all', '~> 3.0')
  spec.add_runtime_dependency('ruby-progressbar')

  spec.add_development_dependency('awesome_print')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('haml')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('slim')

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib assets]

  spec.post_install_message = <<~POST_INSTALL_MESSAGE
    #{'*' * 80}

      rails_best_practices is a code metric tool to check the quality of rails codes.

      I highly recommend you browse the Rails Best Practices website first.

          http://rails-bestpractices.com

      Enjoy!

          Richard Huang (flyerhzm@gmail.com)

    #{'*' * 80}
  POST_INSTALL_MESSAGE
end
