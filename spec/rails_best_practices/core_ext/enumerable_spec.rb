require 'spec_helper'

describe Enumerable do
  it "should get duplications in enumerable" do
    ["hello", "world", "hello", "java"].dups.should == ["hello"]
  end
end
