require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::LawOfDemeterCheck do
  
  describe "belongs_to" do
    before(:each) do
      @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::LawOfDemeterCheck.new)

      content = <<-EOF
      class Invoice < ActiveRecord::Base
        belongs_to :user
      end
      EOF
      @runner.check('app/models/invoice.rb', content)
    end

    it "should law of demeter" do
      content = <<-EOF
      <%= @invoice.user.name %>
      <%= @invoice.user.address %>
      <%= @invoice.user.cellphone %>
      EOF
      @runner.check('app/views/invoices/show.html.erb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/views/invoices/show.html.erb:1 - law of demeter"
    end

    it "should law of demeter" do
      content = <<-EOF
= @invoice.user.name
= @invoice.user.address
= @invoice.user.cellphone
      EOF
      @runner.check('app/views/invoices/show.html.haml', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/views/invoices/show.html.haml:1 - law of demeter"
    end

    it "should no law of demeter" do
      content = <<-EOF
      <%= @invoice.user_name %>
      <%= @invoice.user_address %>
      <%= @invoice.user_cellphone %>
      EOF
      @runner.check('app/views/invoices/show.html.erb', content)
      errors = @runner.errors
      errors.should be_empty
    end
  end

  describe "has_one" do
    before(:each) do
      @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::LawOfDemeterCheck.new)

      content = <<-EOF
      class Invoice < ActiveRecord::Base
        has_one :price
      end
      EOF
      @runner.check('app/models/invoice.rb', content)
    end

    it "should law of demeter" do
      content = <<-EOF
      <%= @invoice.price.currency %>
      <%= @invoice.price.number %>
      EOF
      @runner.check('app/views/invoices/show.html.erb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/views/invoices/show.html.erb:1 - law of demeter"
    end
  end
end
