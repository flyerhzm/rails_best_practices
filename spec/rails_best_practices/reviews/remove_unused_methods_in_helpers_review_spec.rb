require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe RemoveUnusedMethodsInHelpersReview do
      let(:runner) { Core::Runner.new(
        prepares: [Prepares::ControllerPrepare.new, Prepares::HelperPrepare.new],
        reviews: RemoveUnusedMethodsInHelpersReview.new(except_methods: [])
      ) }

      it "should remove unused methods" do
        content =<<-EOF
        module PostsHelper
          def unused; end
        end
        EOF
        runner.prepare('app/helpers/posts_helper.rb', content)
        runner.review('app/helpers/posts_helper.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:2 - remove unused methods (PostsHelper#unused)")
      end

      it "should not remove unused methods if called on views" do
        content =<<-EOF
        module PostsHelper
          def used?(post); end
        end
        EOF
        runner.prepare('app/helpers/posts_helper.rb', content)
        runner.review('app/helpers/posts_helper.rb', content)
        content =<<-EOF
        <% if used?(@post) %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not remove unused methods if called on helpers" do
        content =<<-EOF
        module PostsHelper
          def used?(post)
            test?(post)
          end

          def test?(post); end
        end
        EOF
        runner.prepare('app/helpers/posts_helper.rb', content)
        runner.review('app/helpers/posts_helper.rb', content)
        content =<<-EOF
        <% if used?(@post) %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not remove unused methods if called on controllers" do
        helper_content =<<-EOF
        module PostsHelper
          def used?(post); end
        end
        EOF
        controller_content =<<-EOF
        class PostsController < InheritedResources::Base
          include PostsHelper

          def show
            @post = Post.find(params[:id])
            used?(@post)
          end
        end
        EOF
        runner.prepare('app/helpers/posts_helper.rb', helper_content)
        runner.prepare('app/controllers/posts_controller.rb', controller_content)
        runner.after_prepare
        runner.review('app/helpers/posts_helper.rb', helper_content)
        runner.review('app/controllers/posts_controller.rb', controller_content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not remove unused methods if called in descendant controllers" do
        application_helper_content =<<-EOF
        module ApplicationHelper
          def admin?; end
        end
        EOF
        application_controller_content =<<-EOF
        class ApplicationController
          include ApplicationHelper
        end
        EOF
        controller_content =<<-EOF
        class PostsController < ApplicationController

          def show
            head(:forbidden) unless admin?
          end
        end
        EOF
        runner.prepare('app/helpers/application_helper.rb', application_helper_content)
        runner.prepare('app/controllers/application_controller.rb', application_controller_content)
        runner.prepare('app/controllers/posts_controller.rb', controller_content)
        runner.after_prepare
        runner.review('app/helpers/application_helper.rb', application_helper_content)
        runner.review('app/controllers/application_controller.rb', application_controller_content)
        runner.review('app/controllers/posts_controller.rb', controller_content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

       it "should not check ignored files" do
        runner = Core::Runner.new(prepares: [Prepares::ControllerPrepare.new, Prepares::HelperPrepare.new],
                                  reviews: RemoveUnusedMethodsInHelpersReview.new(ignored_files: /posts_helper/, except_methods: []))

        content =<<-EOF
        module PostsHelper
          def unused; end
        end
        EOF
        runner.prepare('app/helpers/posts_helper.rb', content)
        runner.review('app/helpers/posts_helper.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
       end
    end
  end
end
