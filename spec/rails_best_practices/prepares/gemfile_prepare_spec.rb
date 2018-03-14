# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe GemfilePrepare do
      let(:runner) { Core::Runner.new(prepares: GemfilePrepare.new) }

      context 'gemfile' do
        it 'should parse gems' do
          content = <<-EOF
GEM
  remote: https://rubygems.org/
  specs:
    rails (3.2.13)
      actionmailer (= 3.2.13)
      actionpack (= 3.2.13)
      activerecord (= 3.2.13)
      activeresource (= 3.2.13)
      activesupport (= 3.2.13)
      bundler (~> 1.0)
      railties (= 3.2.13)
    mysql2 (0.3.12b6)

PLATFORMS
  ruby
          EOF
          runner.prepare('Gemfile.lock', content)
          gems = Prepares.gems
          expect(gems.map(&:to_s)).to eq(['rails (3.2.13)', 'mysql2 (0.3.12b6)'])
        end
      end
    end
  end
end
