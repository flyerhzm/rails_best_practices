require 'spec_helper'

describe RailsBestPractices::Reviews::Review do
  before :each do
    @check = RailsBestPractices::Reviews::Review.new
  end

  it "should get empty interesting prepare nodes" do
    @check.interesting_prepare_nodes.should == []
  end

  it "should get empty interesting review nodes" do
    @check.interesting_review_nodes.should == []
  end

  it "should match all files of interesting prepare files" do
    @check.interesting_prepare_files.should == /.*/
  end

  it "should match all files of interesting review files" do
    @check.interesting_review_files.should == /.*/
  end

  context "review_node_start" do
    it "should call review_start_if" do
      node = stub(:node_type => :if)
      @check.should_receive(:send).with("review_start_if", node)
      @check.review_node_start(node)
    end

    it "should call review_start_call" do
      node = stub(:node_type => :call)
      @check.should_receive(:send).with("review_start_call", node)
      @check.review_node_start(node)
    end
  end

  context "review_node_end" do
    it "should call review_end_if" do
      node = stub(:node_type => :if)
      @check.should_receive(:send).with("review_end_if", node)
      @check.review_node_end(node)
    end

    it "should call review_end_call" do
      node = stub(:node_type => :call)
      @check.should_receive(:send).with("review_end_call", node)
      @check.review_node_end(node)
    end
  end

  context "equal?" do
    it "should be true when compare symbol string with symbol" do
      @check.equal?(":test", :test).should be_true
    end
  end
end
