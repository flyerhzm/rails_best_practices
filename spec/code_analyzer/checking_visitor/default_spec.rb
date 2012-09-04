require "spec_helper"

module CodeAnalyzer::CheckingVisitor
  describe Default do
    let(:checker1) { mock(:checker, interesting_nodes: [:class, :def]) }
    let(:checker2) { mock(:checker, interesting_nodes: [:def, :call]) }
    let(:visitor) { Default.new(checkers: [checker1, checker2]) }

    it "should check def node by all checkers" do
      filename = "filename"
      content = "def test; end"
      checker1.stub(:parse_file?).with(filename).and_return(true)
      checker2.stub(:parse_file?).with(filename).and_return(true)
      checker1.should_receive(:node_start)
      checker1.should_receive(:node_end)
      checker2.should_receive(:node_start)
      checker2.should_receive(:node_end)

      visitor.check(filename, content)
    end

    it "should check class node by only checker1" do
      filename = "filename"
      content = "class Test; end"
      checker1.stub(:parse_file?).with(filename).and_return(true)
      checker1.should_receive(:node_start)
      checker1.should_receive(:node_end)

      visitor.check(filename, content)
    end

    it "should check call node by only checker2" do
      filename = "filename"
      content = "obj.message"
      checker2.stub(:parse_file?).with(filename).and_return(true)
      checker2.should_receive(:node_start)
      checker2.should_receive(:node_end)

      visitor.check(filename, content)
    end
  end
end
