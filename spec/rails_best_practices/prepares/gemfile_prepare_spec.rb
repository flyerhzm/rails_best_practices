require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe GemfilePrepare do
      let(:runner) { Core::Runner.new(prepares: GemfilePrepare.new) }

      context "gemfile" do
        it "should parse gems" do
          content =<<-EOF
          source 'http://rubygems.org'
          gem 'rails'
          gem 'mysql2'
          EOF
          runner.prepare('Gemfile', content)
          gems = Prepares.gems
          gems.should == %w(rails mysql2)
        end
      end
    end
  end
end
