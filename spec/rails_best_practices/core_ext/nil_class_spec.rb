require 'spec_helper'

describe NilClass do
  it "should return nil when calling undefined methods on nil" do
    nil.undefined.should == nil
  end

  it "should do not return nil when calling exist methods" do
    nil.nil?.should be_true
  end
end
