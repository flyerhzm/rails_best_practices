require 'spec_helper'

describe RailsBestPractices::Prepares::ControllerPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::ControllerPrepare.new) }

  before :each do
    runner.whiny = true
  end

  context "methods" do
    it "should parse controller methods" do
      content =<<-EOF
      class PostsController < ApplicationController
        def index; end
        def show; end
      end
      EOF
      runner.prepare('app/controllers/posts_controller.rb', content)
      methods = RailsBestPractices::Prepares.controller_methods
      methods.get_methods("PostsController").should == ["index", "show"]
    end

    it "should parse controller methods with module ::" do
      content =<<-EOF
      class Admin::Blog::PostsController < ApplicationController
        def index; end
        def show; end
      end
      EOF
      runner.prepare('app/controllers/admin/posts_controller.rb', content)
      methods = RailsBestPractices::Prepares.controller_methods
      methods.get_methods("Admin::Blog::PostsController").should == ["index", "show"]
    end

    it "should parse controller methods with module" do
      content =<<-EOF
      module Admin
        module Blog
          class PostsController < ApplicationController
            def index; end
            def show; end
          end
        end
      end
      EOF
      runner.prepare('app/controllers/admin/posts_controller.rb', content)
      methods = RailsBestPractices::Prepares.controller_methods
      methods.get_methods("Admin::Blog::PostsController").should == ["index", "show"]
    end

    context "inherited_resources" do
      it "extend inherited_resources" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").should == ["index", "show", "new", "create", "edit", "update", "destroy"]
      end

      it "extend inherited_resources with actions" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
          actions :index, :show
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").should == ["index", "show"]
      end

      it "DSL inherit_resources" do
        content =<<-EOF
        class PostsController
          inherit_resources
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").should == ["index", "show", "new", "create", "edit", "update", "destroy"]
      end
    end
  end
end
