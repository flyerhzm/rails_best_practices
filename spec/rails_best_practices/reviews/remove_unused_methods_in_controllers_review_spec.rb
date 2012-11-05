require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe RemoveUnusedMethodsInControllersReview do
      let(:runner) { Core::Runner.new(
        prepares: [Prepares::ControllerPrepare.new, Prepares::RoutePrepare.new],
        reviews: RemoveUnusedMethodsInControllersReview.new({'except_methods' => ["ExceptableController#*"]})
      ) }

      context "private/protected" do
        it "should remove unused methods" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts do
              member do
                post 'link_to/:other_id' => 'posts#link_to_post'
                post 'extra_update' => 'posts#extra_update'
              end
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < ActiveRecord::Base
            def show; end
            def extra_update; end
            def link_to_post; end
            protected
            def load_post; end
            private
            def load_user; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(2).errors
          runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:6 - remove unused methods (PostsController#load_post)"
          runner.errors[1].to_s.should == "app/controllers/posts_controller.rb:8 - remove unused methods (PostsController#load_user)"
        end

        it "should not remove unused methods for before_filter" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < ActiveRecord::Base
            before_filter :load_post, :load_user
            def show; end
            protected
            def load_post; end
            def load_user; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove unused methods for around_filter" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < ActiveRecord::Base
            around_filter :set_timestamp
            protected
              def set_timestamp
                Time.zone = "Pacific Time (US & Canada)"
                yield
              ensure
                Time.zone = "UTC"
              end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove unused methods for layout" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < ActiveRecord::Base
            layout :choose_layout
            private
              def choose_layout
                "default"
              end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove inherited_resources methods" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < InheritedResources::Base
            def show; end
            protected
            def resource; end
            def collection; end
            def begin_of_association_chain; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end
      end

      context "public" do
        it "should remove unused methods" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show; end
            def list; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:3 - remove unused methods (PostsController#list)"
        end

        it "should not remove unused methods if all actions are used in route" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.connect 'internal/:action/*whatever', controller: "internal"
          end
          EOF
          runner.prepare('config/routes.rb', content)
          content =<<-EOF
          class InternalController < ApplicationController
            def list; end
            def delete; end
            def whatever; end
          end
          EOF
          runner.prepare('app/controllers/internal_controller.rb', content)
          runner.review('app/controllers/internal_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove unused methods if they are except_methods" do
          content =<<-EOF
          class ExceptableController < ApplicationController
            def list; end
          end
          EOF
          runner.prepare('app/controllers/exceptable_controller.rb', content)
          runner.review('app/controllers/exceptable_controller.rb', content)
          runner.after_review
          runner.should have(0).errors
        end
      end

      context "helper_method" do
        it "should remove unused methods if helper method is not called" do
          content = <<-EOF
          class PostsController < ApplicationController
            helper_method :helper_post
            protected
              def helper_post; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:4 - remove unused methods (PostsController#helper_post)"
        end

        it "should not remove unused methods if call helper method in views" do
          content = <<-EOF
          class PostsController < ApplicationController
            helper_method :helper_post
            protected
              def helper_post; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          content = <<-EOF
          <%= helper_post %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove unused methods if call helper method in helpers" do
          content = <<-EOF
          class PostsController < ApplicationController
            helper_method :helper_post
            protected
              def helper_post; end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          content = <<-EOF
          module PostsHelper
            def new_post
              helper_post
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.after_review
          runner.should have(0).errors
        end
      end

      context "delegate to: :controller" do
        it "should remove unused methods if delegate method is not called" do
          content = <<-EOF
          class PostsController < ApplicationController
            protected
              def helper_post(type); end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          content = <<-EOF
          module PostsHelper
            delegate :helper_post, to: :controller
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.after_review
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:3 - remove unused methods (PostsController#helper_post)"
        end

        it "should remove unused methods if delegate method is called" do
          content = <<-EOF
          class PostsController < ApplicationController
            protected
              def helper_post(type); end
          end
          EOF
          runner.prepare('app/controllers/posts_controller.rb', content)
          runner.review('app/controllers/posts_controller.rb', content)
          content = <<-EOF
          module PostsHelper
            delegate :helper_post, to: :controller
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          content = <<-EOF
          <%= helper_post("new") %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          runner.after_review
          runner.should have(0).errors
        end
      end

      context "cells" do
        it "should remove unused methods" do
          content =<<-EOF
          class PostsCell < Cell::Rails
            def list; end
          end
          EOF
          runner.prepare('app/cells/posts_cell.rb', content)
          runner.review('app/cells/posts_cell.rb', content)
          runner.after_review
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/cells/posts_cell.rb:2 - remove unused methods (PostsCell#list)"
        end

        it "should not remove unused methods if render_cell" do
          content =<<-EOF
          class PostsCell < Cell::Rails
            def list; end
            def display; end
          end
          EOF
          runner.prepare('app/cells/posts_cell.rb', content)
          runner.review('app/cells/posts_cell.rb', content)
          content =<<-EOF
          <%= render_cell :posts, :list %>
          <%= render_cell(:posts, :display) %>
          EOF
          runner.review('app/views/posts/index.html.erb', content)
          runner.after_review
          runner.should have(0).errors
        end

        it "should not remove unused methods if render with state" do
          content =<<-EOF
          class PostsCell < Cell::Rails
            def list
              render state: :show
              render(state: :display)
            end

            def show; end
            def display; end
          end
          EOF
          runner.prepare('app/cells/posts_cell.rb', content)
          runner.review('app/cells/posts_cell.rb', content)
          content =<<-EOF
          <%= render_cell :posts, :list %>
          EOF
          runner.review('app/views/posts/index.html.erb', content)
          runner.after_review
          runner.should have(0).errors
        end
      end
    end
  end
end
