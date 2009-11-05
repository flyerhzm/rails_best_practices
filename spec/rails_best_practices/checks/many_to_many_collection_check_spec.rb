require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::ManyToManyCollectionCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::ManyToManyCollectionCheck.new)
  end
  
  it "should many to many collection check" do
    pending
  end
end
