require 'spec_helper'

describe RailsBestPractices::Core::Klasses do
  it { should be_a_kind_of Array }

  context "Klass" do
    it "should get to_s" do
      klass = RailsBestPractices::Core::Klass.new("BlogPost", "Post", ["Admin"])
      klass.to_s.should == "Admin::BlogPost"
    end
  end
end
