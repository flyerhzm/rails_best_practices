require 'spec_helper'

module RailsBestPractices::Core
  describe Klasses do
    it { should be_a_kind_of Array }

    context "Klass" do
      it "should get to_s" do
        klass = Klass.new("BlogPost", "Post", ["Admin"])
        klass.to_s.should == "Admin::BlogPost"
      end
    end
  end
end
