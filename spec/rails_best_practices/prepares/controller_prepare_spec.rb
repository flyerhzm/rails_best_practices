require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe ControllerPrepare do
      let(:runner) { Core::Runner.new(prepares: [ControllerPrepare.new, HelperPrepare.new]) }

      context "methods" do
        it "should parse controller methods" do
          content =<<-EOF
          class PostsController < ApplicationController
            def index; end
            def show; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          methods = Prepares.controller_methods
          expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show"])
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
          methods = Prepares.controller_methods
          expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show", "resources", "resource"])
          expect(methods.get_methods("PostsController", "public").map(&:method_name)).to eq(["index", "show"])
          expect(methods.get_methods("PostsController", "protected").map(&:method_name)).to eq(["resources"])
          expect(methods.get_methods("PostsController", "private").map(&:method_name)).to eq(["resource"])
        end

        it "should parse controller methods with module ::" do
          content =<<-EOF
          class Admin::Blog::PostsController < ApplicationController
            def index; end
            def show; end
          end
          EOF
          runner.prepare('app/controllers/admin/posts_controller.rb', content)
          methods = Prepares.controller_methods
          expect(methods.get_methods("Admin::Blog::PostsController").map(&:method_name)).to eq(["index", "show"])
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
          methods = Prepares.controller_methods
          expect(methods.get_methods("Admin::Blog::PostsController").map(&:method_name)).to eq(["index", "show"])
        end

        context "inherited_resources" do
          it "extend inherited_resources" do
            content =<<-EOF
            class PostsController < InheritedResources::Base
            end
            EOF
            runner.prepare('app/controllers/posts_controller.rb', content)
            methods = Prepares.controller_methods
            expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show", "new", "create", "edit", "update", "destroy"])
          end

          it "extend inherited_resources with actions" do
            content =<<-EOF
            class PostsController < InheritedResources::Base
              actions :index, :show
            end
            EOF
            runner.prepare('app/controllers/posts_controller.rb', content)
            methods = Prepares.controller_methods
            expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show"])
          end

          it "extend inherited_resources with all actions" do
            content =<<-EOF
            class PostsController < InheritedResources::Base
              actions :all, except: [:show]
            end
            EOF
            runner.prepare('app/controllers/posts_controller.rb', content)
            methods = Prepares.controller_methods
            expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "new", "create", "edit", "update", "destroy"])
          end

          it "extend inherited_resources with all actions with no arguments" do
            content =<<-EOF
            class PostsController < InheritedResources::Base
              actions :all
            end
            EOF
            runner.prepare('app/controllers/posts_controller.rb', content)
            methods = Prepares.controller_methods
            expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show", "new", "create", "edit", "update", "destroy"])
          end

          it "DSL inherit_resources" do
            content =<<-EOF
            class PostsController
              inherit_resources
            end
            EOF
            runner.prepare('app/controllers/posts_controller.rb', content)
            methods = Prepares.controller_methods
            expect(methods.get_methods("PostsController").map(&:method_name)).to eq(["index", "show", "new", "create", "edit", "update", "destroy"])
          end
        end
      end

      context "helpers" do
        it "should add helper descendant" do
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
          helpers = Prepares.helpers
          expect(helpers.first.descendants).to eq(["PostsController"])
        end
      end
    end
  end
end
