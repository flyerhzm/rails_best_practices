require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::NestedModelFormsCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::NestedModelFormsCheck.new)
  end
  
  it "should nested model form check" do
    pending
  end
end
