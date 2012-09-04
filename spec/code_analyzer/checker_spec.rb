require 'spec_helper'

module CodeAnalyzer
  describe Checker do
    let(:checker) { Checker.new }


    it "should get empty interesting nodes" do
      checker.interesting_nodes.should == []
    end

    it "should match none of interesting files" do
      checker.interesting_files.should == []
    end

    context "#parse_file?" do
      it "should return true if node_file matches pattern" do
        checker.stub(:interesting_files).and_return([/spec\/.*\.rb/, /lib\/.*\.rb/])
        checker.parse_file?("lib/code_analyzer.rb").should be_true
      end

      it "should return false if node_file doesn't match pattern" do
        checker.stub(:interesting_files).and_return([/spec\/.*\.rb/])
        checker.parse_file?("lib/code_analyzer.rb").should be_false
      end
    end
  end
end
