require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::ReplaceComplexCreationWithFactoryMethodCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::ReplaceComplexCreationWithFactoryMethodCheck.new)
  end
  
  it "should replace complex creation with factory method" do
    content = <<-EOF
    class InvoiceController < ApplicationController
      
      def create
        @invoice = Invoice.new(params[:invoice])
        @invoice.address = current_user.address
        @invoice.phone = current_user.phone
        @invoice.vip = (@invoice.amount > 1000)
        
        if Time.now.day > 15
          @invoice.deliver_time = Time.now + 2.month
        else
          @invoice.deliver_time = Time.now + 1.month
        end
        
        @invoice.save
      end
    end
    EOF
    @runner.check('app/controllers/invoices_controller.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/controllers/invoices_controller.rb:3 - replace complex creation with factory method (@invoice attribute_assignment_count > 2)"
  end

  it "should not replace complex creation with factory method with simple creation" do
    content = <<-EOF
    class InvoiceController < ApplicationController

      def create
        @invoice = Invoice.new(params[:invoice])
        @invoice.address = current_user.address
        @invoice.phone = current_user.phone
        @invoice.save
      end
    end
    EOF
    @runner.check('app/controllers/invoices_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not replace complex creation with factory method when attrasgn_count is 5" do
    content = <<-EOF
    class InvoiceController < ApplicationController

      def create
        @invoice = Invoice.new(params[:invoice])
        @invoice.address = current_user.address
        @invoice.phone = current_user.phone
        @invoice.vip = (@invoice.amount > 1000)

        if Time.now.day > 15
          @invoice.deliver_time = Time.now + 2.month
        else
          @invoice.deliver_time = Time.now + 1.month
        end

        @invoice.save
      end
    end
    EOF
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::ReplaceComplexCreationWithFactoryMethodCheck.new('attribute_assignment_count' => 5))
    @runner.check('app/controllers/invoices_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
