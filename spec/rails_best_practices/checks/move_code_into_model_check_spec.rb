require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::MoveCodeIntoModelCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::MoveCodeIntoModelCheck.new)
  end

  it "should move code into model" do
    content =<<-EOF
    <% if current_user && (current_user == @post.user || @post.editors.include?(current_user)) %>
      <%= link_to 'Edit this post', edit_post_url(@post) %>
    <% end %>
    EOF
    @runner.check('app/views/posts/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/show.html.erb:1 - move code into model (@post)"
  end

  it "should move code into model with haml" do
    content =<<-EOF
- if current_user && (current_user == @post.user || @post.editors.include?(current_user))
  = link_to 'Edit this post', edit_post_url(@post)
    EOF
    @runner.check('app/views/posts/show.html.haml', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/show.html.haml:1 - move code into model (@post)"
  end
  
  it "should move code into model only check for current if conditional statement" do
    content =<<-EOF
    <% if @post.title %>
      <% if @post.user %>
        <% if @post.description %>
        <% end %>
      <% end %>
    <% end %>
    EOF
    @runner.check('app/views/posts/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not move code into model" do
    content =<<-EOF
    <% if @post.editable_by?(current_user) %>
      <%= link_to 'Edit this post', edit_post_url(@post) %>
    <% end %>
    EOF
    @runner.check('app/views/posts/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
