require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe SimplifyRenderInViewsReview do
      let(:runner) { Core::Runner.new(reviews: SimplifyRenderInViewsReview.new) }

      it "should simplify render simple partial" do
        content =<<-EOF
        <%= render partial: 'sidebar' %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
      end

      it "should simplify render partial with object" do
        content =<<-EOF
        <%= render partial: 'post', object: @post %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
      end

      it "should simplify render partial with collection" do
        content =<<-EOF
        <%= render partial: 'posts', collection: @posts %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
      end

      it "should simplify render partial with local variables" do
        content =<<-EOF
        <%= render partial: 'comment', locals: { parent: post } %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
      end

      it "should not simplify render simple partial" do
        content =<<-EOF
        <%= render 'sidebar' %>
        <%= render 'shared/sidebar' %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end

      it "should not simplify render partial with object" do
        content =<<-EOF
        <%= render @post %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end

      it "should not simplify render partial with collection" do
        content =<<-EOF
        <%= render @posts %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end

      it "should not simplify render partial with local variables" do
        content =<<-EOF
        <%= render 'comment', parent: post %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end

      it "should not simplify render partial with complex partial" do
        content =<<-EOF
        <%= render partial: 'shared/post', object: @post %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end

      it "should not simplify render partial with layout option" do
        content =<<-EOF
        <%= render partial: 'post', layout: 'post' %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end
    end
  end
end
