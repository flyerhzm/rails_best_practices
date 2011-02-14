require 'spec_helper'

describe RailsBestPractices::Reviews::MoveCodeIntoControllerReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(:reviews => RailsBestPractices::Reviews::MoveCodeIntoControllerReview.new) }

  it "should move code into controller" do
    content = <<-EOF
    <% @posts = Post.find(:all) %>
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
