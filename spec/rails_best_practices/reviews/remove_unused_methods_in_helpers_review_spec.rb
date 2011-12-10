require 'spec_helper'

describe RailsBestPractices::Reviews::RemoveUnusedMethodsInHelpersReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(
    :prepares => [RailsBestPractices::Prepares::ControllerPrepare.new, RailsBestPractices::Prepares::HelperPrepare.new],
    :reviews => RailsBestPractices::Reviews::RemoveUnusedMethodsInHelpersReview.new(:except_methods => [])
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
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - remove unused methods (PostsHelper#unused)"
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
    runner.should have(0).errors
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
    runner.should have(0).errors
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
    runner.should have(0).errors
  end
end
