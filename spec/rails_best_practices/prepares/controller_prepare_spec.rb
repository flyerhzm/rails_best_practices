require 'spec_helper'

describe RailsBestPractices::Prepares::ControllerPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::ControllerPrepare.new) }

  before :each do
    runner.whiny = true
  end

  it "should parse controller methods" do
    content =<<-EOF
    class PostsController < ApplicationController
      def index
      end

      def show
      end
    end
    EOF
    runner.prepare('app/controllers/posts_controller.rb', content)
    methods = RailsBestPractices::Prepares.controller_methods
    methods.get_methods("PostsController").should == ["index", "show"]
  end
end
