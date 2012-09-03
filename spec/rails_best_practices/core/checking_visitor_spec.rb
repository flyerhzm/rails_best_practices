# encoding: utf-8
require 'spec_helper'

module RailsBestPractices::Core

  class TestLexical1; end
  class TestLexical2; end
  class TestPrepare1 < Check
    interesting_nodes :call
    interesting_files MODEL_FILES
  end

  class TestPrepare2 < Check
    interesting_nodes :class
    interesting_files MAILER_FILES
  end

  class TestReview1 < Check
    interesting_nodes :defn
    interesting_files CONTROLLER_FILES
  end

  class TestReview2 < Check
    interesting_nodes :call
    interesting_files VIEW_FILES
  end

  describe CheckingVisitor do
    let(:lexical1) { TestLexical1.new }
    let(:lexical2) { TestLexical2.new }
    let(:prepare1) { TestPrepare1.new }
    let(:prepare2) { TestPrepare2.new }
    let(:review1) { TestReview1.new }
    let(:review2) { TestReview2.new }
    let(:lexical_visitor) { LexicalCheckingVisitor.new(checkers: [lexical1, lexical2]) }
    let(:prepare_visitor) { CheckingVisitor.new(checkers: [prepare1, prepare2]) }
    let(:review_visitor) { CheckingVisitor.new(checkers: [review1, review2]) }

    it "should lexical check" do
      filename = "app/models/user.rb"
      content = "class User; end"
      lexical1.should_receive(:check).with(filename, content)
      lexical2.should_receive(:check).with(filename, content)
      lexical_visitor.check(filename, content)
    end

    it "should prepare model associations" do
      node = stub(sexp_type: :call, children: [], file: "app/models/user.rb")
      prepare1.should_receive(:node_start).with(node)
      prepare1.should_receive(:node_end).with(node)
      prepare_visitor.check(node)
    end

    it "should prepare mailer names" do
      node = stub(sexp_type: :class, children: [], file: "app/mailers/user_mailer.rb")
      prepare2.should_receive(:node_start).with(node)
      prepare2.should_receive(:node_end).with(node)
      prepare_visitor.check(node)
    end

    it "should review controller method definitions" do
      node = stub(sexp_type: :defn, children: [], file: "app/controllers/users_controller.rb")
      review1.should_receive(:node_start).with(node)
      review1.should_receive(:node_end).with(node)
      review_visitor.check(node)
    end

    it "should review view calls" do
      node = stub(sexp_type: :call, children: [], file: "app/views/users/new.html.erb")
      review2.should_receive(:node_start).with(node)
      review2.should_receive(:node_end).with(node)
      review_visitor.check(node)
    end
  end
end
