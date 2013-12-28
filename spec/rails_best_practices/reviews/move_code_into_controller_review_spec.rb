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
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("app/views/posts/index.html.erb:1 - move code into controller")
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
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("app/views/posts/index.html.erb:1 - move code into controller")
      end

      it "should not move code into controller" do
        content = <<-EOF
        <% @posts.each do |post| %>
          <%=h post.title %>
          <%=h post.content %>
        <% end %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(reviews: MoveCodeIntoControllerReview.new(ignored_files: /app\/views\/post/))
        content = <<-EOF
        <% Post.find(:all).each do |post| %>
          <%=h post.title %>
          <%=h post.content %>
        <% end %>
        EOF
        runner.review('app/views/posts/index.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
