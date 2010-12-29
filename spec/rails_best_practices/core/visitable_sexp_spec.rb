require 'spec_helper'

describe Sexp do
  before :each do
    @parser = RubyParser.new
  end

  describe "children" do
    it "should get all child nodes" do
      node = @parser.parse("puts 'hello ', 'world'")
      node.children.should == [s(:arglist, s(:str, "hello "), s(:str, "world"))]
    end
  end

  describe "recursive_children" do
    it "should get all recursive child nodes" do
      node = @parser.parse("puts 'hello', dynamic_output")
      children = []
      node.recursive_children { |child| children << child }
      children.should == [s(:arglist, s(:str, "hello"), s(:call, nil, :dynamic_output, s(:arglist))), s(:str, "hello"), s(:call, nil, :dynamic_output, s(:arglist)), s(:arglist)]
    end
  end

  describe "grep_nodes" do
    before :each do
      content = <<-EOF
      def show
        current_user.posts.find(params[:id])
      end
      EOF
      @node = @parser.parse(content)
    end

    it "should get the call nodes with empty arguments" do
      nodes = []
      @node.grep_nodes(:node_type => :call, :arguments => s(:arglist)) { |node| nodes << node }
      nodes.should == [s(:call, s(:call, nil, :current_user, s(:arglist)), :posts, s(:arglist)), s(:call, nil, :current_user, s(:arglist)), s(:call, nil, :params, s(:arglist))]
    end

    it "should get the call nodes with different messages" do
      nodes = []
      @node.grep_nodes(:node_type => :call, :message => [:current_user, :params]) { |node| nodes << node }
      nodes.should == [s(:call, nil, :current_user, s(:arglist)), s(:call, nil, :params, s(:arglist))]
    end
  end

  describe "grep_node" do
    before :each do
      content = <<-EOF
      def show
        current_user.posts.find(params[:id])
      end
      EOF
      @node = @parser.parse(content)
    end

    it "should get first node with empty argument" do
      node = @node.grep_node(:node_type => :call, :arguments => s(:arglist))
      node.should == s(:call, s(:call, nil, :current_user, s(:arglist)), :posts, s(:arglist))
    end
  end

  describe "grep_nodes_count" do
    before :each do
      content = <<-EOF
      def show
        current_user.posts.find(params[:id])
      end
      EOF
      @node = @parser.parse(content)
    end

    it "should get the count of call nodes" do
      @node.grep_nodes_count(:node_type => :call).should == 5
    end
  end

  describe "subject" do
    it "should get subject of attrasgn node" do
      node = @parser.parse("user.name = params[:name]")
      node.subject.should == s(:call, nil, :user, s(:arglist))
    end

    it "should get subject of call node" do
      node = @parser.parse("user.name")
      node.subject.should == s(:call, nil, :user, s(:arglist))
    end

    it "should get subject of iter node" do
      node = @parser.parse("@users.each { |user| p user }")
      node.subject.should == s(:call, s(:ivar, :@users), :each, s(:arglist))
    end
  end

  describe "class_name" do
    it "should get class name of class node" do
      node = @parser.parse("class User; end")
      node.class_name.should == :User
    end
  end

  describe "base_class" do
    it "should get base class of class node" do
      node = @parser.parse("class User < ActiveRecord::Base; end")
      node.base_class.should == s(:colon2, s(:const, :ActiveRecord), :Base)
    end
  end

  describe "left_value" do
    it "should get the left value of lasgn" do
      node = @parser.parse("user = params[:user]")
      node.left_value.should == :user
    end

    it "should get the left value of iasgn" do
      node = @parser.parse("@user = params[:user]")
      node.left_value.should == :@user
    end
  end

  describe "right_value" do
    it "should get the right value of lasgn" do
      node = @parser.parse("user = current_user")
      node.right_value.should == s(:call, nil, :current_user, s(:arglist))
    end

    it "should get the right value of iasgn" do
      node = @parser.parse("@user = current_user")
      node.right_value.should == s(:call, nil, :current_user, s(:arglist))
    end
  end

  describe "message" do
    it "should get the message of attrasgn" do
      node = @parser.parse("user.name = params[:name]")
      node.message.should == :name=
    end

    it "should get the message of call" do
      node = @parser.parse("has_many :projects")
      node.message.should == :has_many
    end
  end

  describe "arguments" do
    it "should get the arguments of attrasgn" do
      node = @parser.parse("post.user = current_user")
      node.arguments.should == s(:arglist, s(:call, nil, :current_user, s(:arglist)))
    end

    it "should get the arguments of call" do
      node = @parser.parse("username == ''")
      node.arguments.should == s(:arglist, s(:str, ""))
    end
  end

  describe "conditional_statement" do
    it "should get conditional statement of if" do
      node = @parser.parse("if current_user.present?; puts current_user.login; end")
      node.conditional_statement.should == s(:call, s(:call, nil, :current_user, s(:arglist)), :present?, s(:arglist))
    end
  end

  describe "true_node" do
    it "should get the true node of if" do
      content = <<-EOF
      if current_user.login?
        current_user.login
      else
        current_user.email
      end
      EOF
      node = @parser.parse(content)
      node.true_node.should == s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist))
    end
  end

  describe "false_node" do
    it "should get the false node of if" do
      content = <<-EOF
      if current_user.login?
        current_user.login
      else
        current_user.email
      end
      EOF
      node = @parser.parse(content)
      node.false_node.should == s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
    end
  end

  describe "method_name" do
    it "should get the method name of defn" do
      node = @parser.parse("def show; end")
      node.method_name.should == :show
    end
  end

  describe "body" do
    it "should get body of iter" do
      node = @parser.parse("resources :posts do; resources :comments; end")
      node.body.should == s(:call, nil, :resources, s(:arglist, s(:lit, :comments)))
    end

    it "should get body of class" do
      node = @parser.parse("class User; def login; end; def email; end; end")
      node.body.should == s(:block, s(:defn, :login, s(:args), s(:scope, s(:block, s(:nil)))),  s(:defn, :email, s(:args), s(:scope, s(:block, s(:nil)))))
    end

    it "should get body of defn" do
      node = @parser.parse("def fullname; first_name + last+name; end")
      node.body.should == s(:block, s(:call, s(:call, s(:call, nil, :first_name, s(:arglist)), :+, s(:arglist, s(:call, nil, :last, s(:arglist)))), :+, s(:arglist, s(:call, nil, :name, s(:arglist)))))
    end
  end

  describe "to_s" do
    it "should get to_s for lvar" do
      node = @parser.parse("user = current_user; user")
      node.children[1].node_type.should == :lvar
      node.children[1].to_s.should == "user"
    end

    it "should get to_s for ivar" do
      node = @parser.parse("@user")
      node.to_s.should == "@user"
    end

    it "should get to_s for str" do
      node = @parser.parse("'user'")
      node.to_s.should == "user"
    end

    it "should get to_s for lit" do
      node = @parser.parse("{:user => 'Richard'}")
      node[1].to_s.should == "user"
    end


    it "should get to_s for const" do
      node = @parser.parse("User")
      node.to_s.should == "User"
    end

    it "should get to_s for array" do
      node = @parser.parse("[@user1, @user2]")
      node.to_s.should == '["@user1", "@user2"]'
    end

    it "should get to_s for hash" do
      node = @parser.parse("{:first_name => 'Richard', :last_name => 'Huang'}")
      node.to_s.should == '{"first_name" => "Richard", "last_name" => "Huang"}'
    end

    it "should get to_s for colon2" do
      node = @parser.parse("RailsBestPractices::Core")
      node.to_s.should == "RailsBestPracticesCore"
    end
  end
end
