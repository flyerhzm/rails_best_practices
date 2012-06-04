require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe AddModelVirtualAttributeReview do
      let(:runner) { Core::Runner.new(reviews: AddModelVirtualAttributeReview.new) }

      it "should add model virtual attribute" do
        content = <<-EOF
        class UsersController < ApplicationController
          def create
            @user = User.new(params[:user])
            @user.first_name = params[:full_name].split(' ', 2).first
            @user.last_name = params[:full_name].split(' ', 2).last
            @user.save
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/users_controller.rb:2 - add model virtual attribute (for @user)"
      end

      it "should add model virtual attribute with local assignment" do
        content = <<-EOF
        class UsersController < ApplicationController
          def create
            user = User.new(params[:user])
            user.first_name = params[:full_name].split(' ', 2).first
            user.last_name = params[:full_name].split(' ', 2).last
            user.save
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/users_controller.rb:2 - add model virtual attribute (for user)"
      end

      it "should not add model virtual attribute with differen param" do
        content = <<-EOF
        class UsersController < ApplicationController
          def create
            @user = User.new(params[:user])
            @user.first_name = params[:first_name]
            @user.last_name = params[:last_name]
            @user.save
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(0).errors
      end

      it "should not add model virtual attribute with read" do
        content = <<-EOF
        class UsersController < ApplicationController
          def show
            if params[:id]
              @user = User.find(params[:id])
            else
              @user = current_user
            end
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(0).errors
      end

      it "should add model virtual attribute with two dimension params" do
        content = <<-EOF
        class UsersController < ApplicationController
          def create
            @user = User.new(params[:user])
            @user.first_name = params[:user][:full_name].split(' ', 2).first
            @user.last_name = params[:user][:full_name].split(' ', 2).last
            @user.save
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/users_controller.rb:2 - add model virtual attribute (for @user)"
      end

      it "should no add model virtual attribute with two dimension params" do
        content = <<-EOF
        class UsersController < ApplicationController
          def create
            @user = User.new(params[:user])
            @user.first_name = params[:user][:first_name]
            @user.last_name = params[:user][:last_name]
            @user.save
          end
        end
        EOF
        runner.review('app/controllers/users_controller.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
