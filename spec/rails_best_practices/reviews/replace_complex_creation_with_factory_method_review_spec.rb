require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe ReplaceComplexCreationWithFactoryMethodReview do
      let(:runner) { Core::Runner.new(reviews: ReplaceComplexCreationWithFactoryMethodReview.new) }

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
        runner.review('app/controllers/invoices_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("app/controllers/invoices_controller.rb:2 - replace complex creation with factory method (@invoice attribute_assignment_count > 2)")
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
        runner.review('app/controllers/invoices_controller.rb', content)
        expect(runner.errors.size).to eq(0)
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
        runner = Core::Runner.new(reviews: ReplaceComplexCreationWithFactoryMethodReview.new('attribute_assignment_count' => 5))
        runner.review('app/controllers/invoices_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(reviews: ReplaceComplexCreationWithFactoryMethodReview.new(ignored_files: /invoices_controller/))
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
        runner.review('app/controllers/invoices_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
