require 'spec_helper'

describe RailsBestPractices::Reviews::Review do
  before :each do
    @check = RailsBestPractices::Reviews::Review.new
  end

  context "equal?" do
    it "should be true when compare symbol string with symbol" do
      @check.equal?(":test", :test).should be_true
    end
  end
end
