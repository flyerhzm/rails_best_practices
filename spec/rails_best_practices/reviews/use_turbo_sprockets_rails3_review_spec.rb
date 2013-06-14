require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseTurboSprocketsRails3Review do
      let(:runner) { Core::Runner.new(prepares: Prepares::GemfilePrepare.new, reviews: UseTurboSprocketsRails3Review.new) }

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
GEM
  remote: http://rubygems.org
  specs:
    rails (3.2.13)
      actionmailer (= 3.2.13)
      actionpack (= 3.2.13)
      activerecord (= 3.2.13)
      activeresource (= 3.2.13)
      activesupport (= 3.2.13)
      bundler (~> 1.0)
      railties (= 3.2.13)
    turbo-sprockets-rails3 (0.3.6)
      railties (> 3.2.8, < 4.0.0)
      sprockets (>= 2.0.0)
        EOF
        runner.prepare('Gemfile.lock', content)
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
