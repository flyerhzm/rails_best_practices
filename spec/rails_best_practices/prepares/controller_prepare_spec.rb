require 'spec_helper'

describe RailsBestPractices::Prepares::ControllerPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(
    :prepares => [RailsBestPractices::Prepares::ControllerPrepare.new, RailsBestPractices::Prepares::HelperPrepare.new]
  ) }

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
      methods.get_methods("PostsController").map(&:method_name).should == ["index", "show"]
    end

    it "should parse model methods with access control" do
      content =<<-EOF
      class PostsController < ApplicationController
        def index; end
        def show; end
        protected
        def resources; end
        private
        def resource; end
      end
      EOF
      runner.prepare('app/controllers/posts_controller.rb', content)
      methods = RailsBestPractices::Prepares.controller_methods
      methods.get_methods("PostsController").map(&:method_name).should == ["index", "show", "resources", "resource"]
      methods.get_methods("PostsController", "public").map(&:method_name).should == ["index", "show"]
      methods.get_methods("PostsController", "protected").map(&:method_name).should == ["resources"]
      methods.get_methods("PostsController", "private").map(&:method_name).should == ["resource"]
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
      methods.get_methods("Admin::Blog::PostsController").map(&:method_name).should == ["index", "show"]
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
      methods.get_methods("Admin::Blog::PostsController").map(&:method_name).should == ["index", "show"]
    end

    context "inherited_resources" do
      it "extend inherited_resources" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").map(&:method_name).should == ["index", "show", "new", "create", "edit", "update", "destroy"]
      end

      it "extend inherited_resources with actions" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
          actions :index, :show
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").map(&:method_name).should == ["index", "show"]
      end

      it "extend inherited_resources with all actions" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
          actions :all, except: [:show]
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").map(&:method_name).should == ["index", "new", "create", "edit", "update", "destroy"]
      end

      it "extend inherited_resources with all actions with no arguments" do
        content =<<-EOF
        class PostsController < InheritedResources::Base
          actions :all
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").map(&:method_name).should == ["index", "show", "new", "create", "edit", "update", "destroy"]
      end

      it "DSL inherit_resources" do
        content =<<-EOF
        class PostsController
          inherit_resources
        end
        EOF
        runner.prepare('app/controllers/posts_controller.rb', content)
        methods = RailsBestPractices::Prepares.controller_methods
        methods.get_methods("PostsController").map(&:method_name).should == ["index", "show", "new", "create", "edit", "update", "destroy"]
      end
    end
  end

  context "helpers" do
    it "should add helper decendant" do
      content =<<-EOF
      module PostsHelper
      end
      EOF
      runner.prepare('app/helpers/posts_helper.rb', content)
      content =<<-EOF
      class PostsController
        include PostsHelper
      end
      EOF
      runner.prepare('app/controllers/posts_controller.rb', content)
      helpers = RailsBestPractices::Prepares.helpers
      helpers.first.decendants.should == ["PostsController"]
    end
  end
end
