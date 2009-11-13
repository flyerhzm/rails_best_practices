require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::ReplaceInstanceVariableWithLocalVariableCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::ReplaceInstanceVariableWithLocalVariableCheck.new)
  end

  it "should replace instance variable with local varialbe" do
    content = <<-EOF
    <%= @post.title %>
    EOF
    @runner.check('app/views/posts/_post.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/_post.html.erb:1 - replace instance variable with local variable"
  end

  it "should replace instance variable with local varialbe in haml file" do
    content = <<-EOF
= @post.title
    EOF
    @runner.check('app/views/posts/_post.html.haml', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/_post.html.haml:1 - replace instance variable with local variable"
  end

  it "should not replace instance variable with local varialbe" do
    content = <<-EOF
    <%= post.title %>
    EOF
    @runner.check('app/views/posts/_post.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
