require 'spec_helper'

module RailsBestPractices::Core
  describe Check do
    let(:check) { Check.new }

    it "should get empty interesting nodes" do
      check.interesting_nodes.should == []
    end

    it "should match none of interesting files" do
      check.interesting_files.should == []
    end

    context "node_start" do
      it "should call start_if" do
        node = stub(:sexp_type => :if)
        check.should_receive(:send).with("start_if", node)
        check.node_start(node)
      end

      it "should call start_call" do
        node = stub(:sexp_type => :call)
        check.should_receive(:send).with("start_call", node)
        check.node_start(node)
      end

      it "should print node if debug mode" do
        node = stub(:sexp_type => :call)
        Check.class_eval { debug }
        check.should_receive(:send).with("start_call", node)
        check.should_receive(:ap).with(node)
        check.node_start(node)
        Check.class_eval { @debug = false }
      end
    end

    context "node_end" do
      it "should call end_if" do
        node = stub(:sexp_type => :if)
        check.should_receive(:send).with("end_if", node)
        check.node_end(node)
      end

      it "should call end_call" do
        node = stub(:sexp_type => :call)
        check.should_receive(:send).with("end_call", node)
        check.node_end(node)
      end
    end

    context "callback" do
      it "should add callback to start_call" do
        execute = false
        check.class.add_callback "start_call" do
          execute = true
        end
        node = stub(:sexp_type => :call)
        check.node_start(node)
        execute.should be_true
      end

      it "should ad callbacks to end_call" do
        execute = false
        check.class.add_callback "end_call" do
          execute = true
        end
        node = stub(:sexp_type => :call)
        check.node_end(node)
        execute.should be_true
      end
    end

    context "debug" do
      it "should be debug mode" do
        Check.debug
        Check.should be_debug
        Check.class_eval { @debug = false }
      end
    end
  end
end
