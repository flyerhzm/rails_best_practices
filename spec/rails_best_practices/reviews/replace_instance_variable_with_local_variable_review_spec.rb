require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe ReplaceInstanceVariableWithLocalVariableReview do
      let(:runner) { Core::Runner.new(reviews: ReplaceInstanceVariableWithLocalVariableReview.new) }

      it "should replace instance variable with local varialbe" do
        content = <<-EOF
        <%= @post.title %>
        EOF
        runner.review('app/views/posts/_post.html.erb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/_post.html.erb:1 - replace instance variable with local variable"
      end

      it "should replace instance variable with local varialbe in haml file" do
        content = <<-EOF
= @post.title
        EOF
        runner.review('app/views/posts/_post.html.haml', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/_post.html.haml:1 - replace instance variable with local variable"
      end

      it "should replace instance variable with local varialbe in slim file" do
        content = <<-EOF
= @post.title
        EOF
        runner.review('app/views/posts/_post.html.slim', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/views/posts/_post.html.slim:1 - replace instance variable with local variable"
      end

      it "should not replace instance variable with local varialbe" do
        content = <<-EOF
        <%= post.title %>
        EOF
        runner.review('app/views/posts/_post.html.erb', content)
        runner.should have(0).errors
      end
    end
  end
end
