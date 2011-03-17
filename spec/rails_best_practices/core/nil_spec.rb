require 'spec_helper'

describe RailsBestPractices::Core::Nil do
  let(:core_nil) { RailsBestPractices::Core::Nil.new }

  context "to_s" do
    it "should return self" do
      core_nil.to_s.should == core_nil
    end
  end

  context "method_missing" do
    it "should return self" do
      core_nil.undefined.should == core_nil
    end
  end
end