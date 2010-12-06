require 'spec_helper'

describe RailsBestPractices::Checks::UseQueryAttributeCheck do

  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseQueryAttributeCheck.new)

    content = <<-EOF
    class User < ActiveRecord::Base
      has_many :projects
      belongs_to :location
      has_one :phone

      belongs_to :category, :class_name => 'IssueCategory', :foreign_key => 'category_id'
    end
    EOF
    @runner.prepare('app/models/user.rb', content)
  end

  it "should use query attribute by blank call" do
    content = <<-EOF
    <% if @user.login.blank? %>
      <%= link_to 'login', new_session_path %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should use query attribute by comparing empty string" do
    content = <<-EOF
    <% if @user.login == "" %>
      <%= link_to 'login', new_session_path %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should use query attribute by nil call" do
    content = <<-EOF
    <% if @user.login.nil? %>
      <%= link_to 'login', new_session_path %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should use query attribute by present call" do
    content = <<-EOF
    <% if @user.login.present? %>
      <%= @user.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should use query attribute within and conditions" do
    content = <<-EOF
    <% if @user.active? and @user.login.present? %>
      <%= @user.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should use query attribute within or conditions" do
    content = <<-EOF
    <% if @user.active? or @user.login != "" %>
      <%= @user.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/views/users/show.html.erb:1 - use query attribute (@user.login?)"
  end

  it "should not use query attribute" do
    content = <<-EOF
    <% if @user.login? %>
      <%= @user.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not check for pluralize attribute" do
    content = <<-EOF
    <% if @user.roles.blank? %>
      <%= @user.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not check non model class" do
    content = <<-EOF
    <% if @person.login.present? %>
      <%= @person.login %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  context "association" do
    it "should not check belongs_to association" do
      content = <<-EOF
      <% if @user.location.present? %>
        <%= @user.location.name %>
      <% end %>
      EOF
      @runner.check('app/views/users/show.html.erb', content)
      errors = @runner.errors
      errors.should be_empty
    end

      it "should not check belongs_to category" do
        content = <<-EOF
        <% if @user.category.present? %>
          <%= @user.category.name %>
        <% end %>
        EOF
        @runner.check('app/views/users/show.html.erb', content)
        errors = @runner.errors
        errors.should be_empty
      end

    it "should not check has_one association" do
      content = <<-EOF
      <% if @user.phone.present? %>
        <%= @user.phone.number %>
      <% end %>
      EOF
      @runner.check('app/views/users/show.html.erb', content)
      errors = @runner.errors
      errors.should be_empty
    end

    it "should not check has_many association" do
      content = <<-EOF
      <% if @user.projects.present? %>
        <%= @user.projects.first.name %>
      <% end %>
      EOF
      @runner.check('app/views/users/show.html.erb', content)
      errors = @runner.errors
      errors.should be_empty
    end
  end

  it "should not check for class method" do
    content = <<-EOF
    <% if User.name.present? %>
      <%= User.name %>
    <% end %>
    EOF
    @runner.check('app/views/users/show.html.erb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not check for non attribute call" do
    content = <<-EOF
    if @user.login(false).nil?
      puts @user.login(false)
    end
    EOF
    @runner.check('app/models/users_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
