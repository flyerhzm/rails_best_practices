# encoding: utf-8
require 'spec_helper'

class TestLexical1
end
class TestLexical2
end
class TestPrepare1
  def interesting_nodes
    [:call]
  end

  def interesting_files
    RailsBestPractices::Core::Check::MODEL_FILES
  end
end

class TestPrepare2
  def interesting_nodes
    [:class]
  end

  def interesting_files
    RailsBestPractices::Core::Check::MAILER_FILES
  end
end

class TestReview1
  def interesting_nodes
    [:defn]
  end

  def interesting_files
    RailsBestPractices::Core::Check::CONTROLLER_FILES
  end
end

class TestReview2
  def interesting_nodes
    [:call]
  end

  def interesting_files
    RailsBestPractices::Core::Check::VIEW_FILES
  end
end

describe RailsBestPractices::Core::CheckingVisitor do
  let(:lexical1) { TestLexical1.new }
  let(:lexical2) { TestLexical2.new }
  let(:prepare1) { TestPrepare1.new }
  let(:prepare2) { TestPrepare2.new }
  let(:review1) { TestReview1.new }
  let(:review2) { TestReview2.new }
  let(:visitor) {
    RailsBestPractices::Core::CheckingVisitor.new(
      :lexicals => [lexical1, lexical2],
      :prepares => [prepare1, prepare2],
      :reviews => [review1, review2]
    )
  }

  it "should lexical check" do
    filename = "app/models/user.rb"
    content = "class User; end"
    lexical1.should_receive(:check).with(filename, content)
    lexical2.should_receive(:check).with(filename, content)
    visitor.lexical(filename, content)
  end

  it "should prepare model associations" do
    node = stub(:node_type => :call, :children => [], :file => "app/models/user.rb")
    prepare1.should_receive(:node_start).with(node)
    prepare1.should_receive(:node_end).with(node)
    visitor.prepare(node)
  end

  it "should prepare mailer names" do
    node = stub(:node_type => :class, :children => [], :file => "app/mailers/user_mailer.rb")
    prepare2.should_receive(:node_start).with(node)
    prepare2.should_receive(:node_end).with(node)
    visitor.prepare(node)
  end

  it "should review controller method definitions" do
    node = stub(:node_type => :defn, :children => [], :file => "app/controllers/users_controller.rb")
    review1.should_receive(:node_start).with(node)
    review1.should_receive(:node_end).with(node)
    visitor.review(node)
  end

  it "should review view calls" do
    node = stub(:node_type => :call, :children => [], :file => "app/views/users/new.html.erb")
    review2.should_receive(:node_start).with(node)
    review2.should_receive(:node_end).with(node)
    visitor.review(node)
  end
end
