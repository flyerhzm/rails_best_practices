require 'spec_helper'

describe RailsBestPractices::Reviews::RemoveUnusedMethodsInHelpersReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(
    :prepares => RailsBestPractices::Prepares::HelperPrepare.new,
    :reviews => RailsBestPractices::Reviews::RemoveUnusedMethodsInHelpersReview.new(:except_methods => [])
  ) }

  it "should remove unused methods" do
    content =<<-EOF
    module PostsHelper < ActiveRecord::Base
      def unused; end
    end
    EOF
    runner.prepare('app/helpers/posts_helper.rb', content)
    runner.review('app/helpers/posts_helper.rb', content)
    runner.on_complete
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - remove unused methods (PostsHelper#unused)"
  end

  it "should not remove unused methods if called on views" do
    content =<<-EOF
    module PostsHelper < ActiveRecord::Base
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
    runner.on_complete
    runner.should have(0).errors
  end

  it "should not remove unused methods if called on helpers" do
    content =<<-EOF
    module PostsHelper < ActiveRecord::Base
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
    runner.on_complete
    runner.should have(0).errors
  end
end
