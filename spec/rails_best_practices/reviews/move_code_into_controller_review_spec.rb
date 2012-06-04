require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe MoveCodeIntoControllerReview do
      let(:runner) { Core::Runner.new(reviews: MoveCodeIntoControllerReview.new) }

      it "should move code into controller for method call" do
        content = <<-EOF
        <% Post.find(:all).each do |post| %>
          <%=h post.title %>
          <%=h post.content %>
        <% end %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - move code into controller"
      end

      it "should move code into controller for assign" do
        content = <<-EOF
        <% @posts = Post.all %>
        <% @posts.each do |post| %>
          <%=h post.title %>
          <%=h post.content %>
        <% end %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - move code into controller"
      end

      it "should not move code into controller" do
        content = <<-EOF
        <% @posts.each do |post| %>
          <%=h post.title %>
          <%=h post.content %>
        <% end %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        runner.should have(0).errors
      end
    end
  end
end
