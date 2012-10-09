require 'spec_helper'

module RailsBestPractices::Core
  describe Error do
    it "should return error with filename, line number and message" do
      Error.new(
        filename: "app/models/user.rb",
        line_number: "100",
        message: "not good",
        type: "BogusReview").to_s.should == "app/models/user.rb:100 - not good"
    end

    it "should return short filename" do
      Runner.base_path = "../rails-bestpractices.com"
      Error.new(
        filename: "../rails-bestpractices.com/app/models/user.rb",
        line_number: "100",
        message: "not good",
        type: "BogusReview").short_filename.should == "app/models/user.rb"
    end

    it "should return first line number" do
      Error.new(
        filename: "app/models/user.rb",
        line_number: "50,70,100",
        message: "not good",
        type: "BogusReview").first_line_number.should == "50"
    end
  end
end
