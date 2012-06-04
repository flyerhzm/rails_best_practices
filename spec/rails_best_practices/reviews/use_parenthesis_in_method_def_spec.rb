require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseParenthesesInMethodDefReview do
      let(:runner) { Core::Runner.new(reviews: UseParenthesesInMethodDefReview.new) }

      it "should find missing parentheses" do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit foo, bar
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:2 - use parentheses around parameters in method definitions"
      end
      it "should find parentheses with no error" do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit(foo, bar)
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
      end
      it "should not throw an error without parameters" do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
