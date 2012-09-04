require 'spec_helper'

module CodeAnalyzer
  describe Checker do
    let(:checker) { Checker.new }

    context "interesting_nodes" do
      it "should get empty interesting nodes" do
        checker.interesting_nodes.should == []
      end

      it "should add interesting nodes" do
        Checker.interesting_nodes :class, :def
        checker.interesting_nodes.should == [:class, :def]
      end
    end

    context "interesting_files" do
      it "should match none of interesting files" do
        checker.interesting_files.should == []
      end

      it "should add interesting files" do
        Checker.interesting_files /lib/, /spec/
        checker.interesting_files.should == [/lib/, /spec/]
      end
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

    context "callback" do
      it "should add callback to start_call" do
        block = Proc.new {}
        Checker.add_callback(:start_call, &block)
        Checker.get_callbacks(:start_call).should == [block]
      end

      it "should add callback to both start_class and end_class" do
        block = Proc.new {}
        Checker.add_callback(:start_class, :end_class, &block)
        Checker.get_callbacks(:start_class).should == [block]
        Checker.get_callbacks(:end_class).should == [block]
      end

      it "should add multiple callbacks to end_call" do
        block1 = Proc.new {}
        block2 = Proc.new {}
        Checker.add_callback(:end_call, &block1)
        Checker.add_callback(:end_call, &block2)
        Checker.get_callbacks(:end_call).should == [block1, block2]
      end
    end
  end
end
