require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseModelCallbackCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseModelCallbackCheck.new)
  end
  
  it "should use model callback check" do
    pending
  end
end