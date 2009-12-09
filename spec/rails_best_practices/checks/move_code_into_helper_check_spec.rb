require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::MoveCodeIntoHelperCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::MoveCodeIntoHelperCheck.new('array_count' => 2))
  end

  it "should move code into helper" do
    content = <<-EOF
    <%= select_tag :state, options_for_select( [[t(:draft), "draft"],
                                                [t(:published), "published"]],
                                               params[:default_state] ) %>
    
    EOF
    @runner.check('app/views/posts/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/posts/show.html.erb:3 - move code into helper (array_count >= 2)"
  end

  it "should not move code into helper with simple arguments" do
    content = <<-EOF
    <%= select_tag :state, options_for_select( Post.STATES ) %>
    EOF
    @runner.check('app/views/posts/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end