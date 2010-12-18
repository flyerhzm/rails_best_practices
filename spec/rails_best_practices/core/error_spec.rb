require 'spec_helper'

describe RailsBestPractices::Core::Error do
  it "should return error with filename, line number and message" do
    RailsBestPractices::Core::Error.new("app/models/user.rb", 100, "not good").to_s.should == "app/models/user.rb:100 - not good"
  end
end
