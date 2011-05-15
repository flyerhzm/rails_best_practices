require 'spec_helper'

describe RailsBestPractices::Reviews::RemoveEmptyHelpersReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(:reviews => RailsBestPractices::Reviews::RemoveEmptyHelpersReview.new) }

  it "should remove empty helpers" do
    content =<<-EOF
    module PostsHelper
    end
    EOF
    runner.review('app/helpers/posts_helper.rb', content)
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:1 - remove empty helpers"
  end

  it "should not remove empty helpers" do
    content =<<-EOF
    module PostsHelper
      def post_link(post)
        post_path(post)
      end
    end
    EOF
    runner.review('app/helpers/posts_helper.rb', content)
    runner.should have(0).errors
  end
end
