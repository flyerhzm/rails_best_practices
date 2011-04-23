require 'spec_helper'

describe RailsBestPractices::Reviews::SimplifyRenderInViewsReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(:reviews => RailsBestPractices::Reviews::SimplifyRenderInViewsReview.new) }

  it "should simplify render simple partial" do
    content =<<-EOF
    <%= render :partial => 'sidebar' %>
    EOF
    runner.review('app/views/posts/index.html.erb', content)
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
  end

  it "should simplify render partial with object" do
    content =<<-EOF
    <%= render :partial => 'posts/post', :object => @post %>
    EOF
    runner.review('app/views/posts/index.html.erb', content)
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
  end

  it "should simplify render partial with collection" do
    content =<<-EOF
    <%= render :partial => 'posts', :collection => @posts %>
    EOF
    runner.review('app/views/posts/index.html.erb', content)
    runner.should have(1).errors
    runner.errors[0].to_s.should == "app/views/posts/index.html.erb:1 - simplify render in views"
  end

  it "should simplify render partial with local variables" do
    content =<<-EOF
    <%= render :partial => 'comments/comment', :locals => { :parent => post } %>
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
    <%= render 'comments/comment', :parent => post %>
    EOF
    runner.review('app/views/posts/index.html.erb', content)
    runner.should have(0).errors
  end
end
