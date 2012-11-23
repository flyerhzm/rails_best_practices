require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseTurboSprocketsRails3 do
      let(:runner) { Core::Runner.new(prepares: Prepares::GemfilePrepare.new, reviews: UseTurboSprocketsRails3.new) }

      it "should use turbo-sprockets-rails3" do
        content = <<-EOF
        source "http://rubygems.org"
        gem "rails"
        EOF
        runner.prepare('Gemfile', content)
        content = <<-EOF
        load 'deploy' if respond_to?(:namespace)
        load 'deploy/assets'
        load 'config/deploy'
        EOF
        runner.review('Capfile', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "Capfile:2 - speed up assets precompile with turbo-sprockets-rails3"
      end

      it "should not use turbo-sprockets-rails3 with turbo-sprockets-rails3 gem" do
        content = <<-EOF
        source "http://rubygems.org"
        gem "rails"
        group :assets do
          gem "turbo-sprockets-rails3"
        end
        EOF
        runner.prepare('Gemfile', content)
        content = <<-EOF
        load 'deploy' if respond_to?(:namespace)
        load 'deploy/assets'
        load 'config/deploy'
        EOF
        runner.review('Capfile', content)
        runner.should have(0).errors
      end

      it "should not use turbo-sprockets-rails3 without deploy/assets" do
        content = <<-EOF
        load 'deploy' if respond_to?(:namespace)
        #load 'deploy/assets'
        load 'config/deploy'
        EOF
        runner.review('Capfile', content)
        runner.should have(0).errors
      end
    end
  end
end

