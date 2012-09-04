require 'spec_helper'

module CodeAnalyzer
  describe Nil do
    let(:core_nil) { Nil.new }

    context "to_s" do
      it "should return self" do
        core_nil.to_s.should == core_nil
      end
    end

    context "hash_size" do
      it "should return 0" do
        core_nil.hash_size.should == 0
      end
    end

    context "method_missing" do
      it "should return self" do
        core_nil.undefined.should == core_nil
      end
    end

    context "present?" do
      it "should return false" do
        core_nil.should_not be_present
      end
    end

    context "blank?" do
      it "should return true" do
        core_nil.should be_blank
      end
    end
  end
end
