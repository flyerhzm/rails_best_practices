require 'spec_helper'

describe RailsBestPractices::Core::Error do
  it "should return error with filename, line number and message" do
    RailsBestPractices::Core::Error.new("app/models/user.rb", "100", "not good", "BogusReview").to_s.should == "app/models/user.rb:100 - not good"
  end

  it "should return short filename" do
    RailsBestPractices::Core::Runner.base_path = "../rails-bestpractices.com"
    RailsBestPractices::Core::Error.new("../rails-bestpractices.com/app/models/user.rb", "100", "not good", "BogusReview").short_filename.should == "app/models/user.rb"
  end

  it "should return first line number" do
    RailsBestPractices::Core::Error.new("app/models/user.rb", "50,70,100", "not good", "BogusReview").first_line_number.should == "50"
  end
end
