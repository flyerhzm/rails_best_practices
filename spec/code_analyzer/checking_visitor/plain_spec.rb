require "spec_helper"

module CodeAnalyzer::CheckingVisitor
  describe Plain do
    let(:checker1) { mock(:checker) }
    let(:checker2) { mock(:checker) }
    let(:visitor) { Plain.new(checkers: [checker1, checker2]) }

    it "should check by all checkers" do
      filename = "filename"
      content = "content"
      checker1.should_receive(:check).with(filename, content)
      checker2.should_receive(:check).with(filename, content)

      visitor.check(filename, content)
    end
  end
end
