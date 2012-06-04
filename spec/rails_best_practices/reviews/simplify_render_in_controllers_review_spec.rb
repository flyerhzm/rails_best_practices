require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe SimplifyRenderInControllersReview do
      let(:runner) { Core::Runner.new(reviews: SimplifyRenderInControllersReview.new) }

      it "should simplify render action view" do
        content =<<-EOF
        def edit
          render action: :edit
        end
        EOF
        runner.review("app/controllers/posts_controller.rb", content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:2 - simplify render in controllers"
      end

      it "should simplify render actions's template" do
        content =<<-EOF
        def edit
          render template: 'books/edit'
        end
        EOF
        runner.review("app/controllers/posts_controller.rb", content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:2 - simplify render in controllers"
      end

      it "should simplify render an arbitrary file" do
        content =<<-EOF
        def edit
          render file: '/path/to/rails/app/views/books/edit'
        end
        EOF
        runner.review("app/controllers/posts_controller.rb", content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:2 - simplify render in controllers"
      end

      it "should not simplify render action view" do
        content =<<-EOF
        render :edit
        EOF
        runner.review("app/controllers/posts_controller", content)
        runner.should have(0).errors
      end

      it "should not simplify render actions's template" do
        content =<<-EOF
        def edit
          render 'books/edit'
        end
        EOF
        runner.review("app/controllers/posts_controller.rb", content)
        runner.should have(0).errors
      end

      it "should not simplify render an arbitrary file" do
        content =<<-EOF
        def edit
          render '/path/to/rails/app/views/books/edit'
        end
        EOF
        runner.review("app/controllers/posts_controller.rb", content)
        runner.should have(0).errors
      end
    end
  end
end
