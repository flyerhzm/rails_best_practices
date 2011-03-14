require 'spec_helper'

describe RailsBestPractices::Core::Check do
  let(:check) { RailsBestPractices::Core::Check.new }

  it "should get empty interesting nodes" do
    check.interesting_nodes.should == RailsBestPractices::Core::Check::NODE_TYPES
  end

  it "should match all files of interesting files" do
    check.interesting_files.should == /.*/
  end

  context "node_start" do
    it "should call start_if" do
      node = stub(:node_type => :if)
      check.should_receive(:send).with("start_if", node)
      check.node_start(node)
    end

    it "should call start_call" do
      node = stub(:node_type => :call)
      check.should_receive(:send).with("start_call", node)
      check.node_start(node)
    end
  end

  context "node_end" do
    it "should call end_if" do
      node = stub(:node_type => :if)
      check.should_receive(:send).with("end_if", node)
      check.node_end(node)
    end

    it "should call end_call" do
      node = stub(:node_type => :call)
      check.should_receive(:send).with("end_call", node)
      check.node_end(node)
    end
  end
end
