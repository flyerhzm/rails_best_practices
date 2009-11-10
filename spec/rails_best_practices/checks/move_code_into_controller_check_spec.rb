require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::MoveCodeIntoControllerCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::MoveCodeIntoControllerCheck.new)
  end
  
  it "should move code into controller" do
    content = <<-EOF
    <% @posts = Post.find(:all) %>
    <% @posts.each do |post| %>
      <%=h post.title %>
      <%=h post.content %>
    <% end %>
    EOF
    @runner.check('app/views/posts/index.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/index.html.erb:1 - move code into controller"
  end

  it "should not move code into controller" do
    content = <<-EOF
    <% @posts.each do |post| %>
      <%=h post.title %>
      <%=h post.content %>
    <% end %>
    EOF
    @runner.check('app/views/posts/index.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end