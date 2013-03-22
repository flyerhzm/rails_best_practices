require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe ProtectMassAssignmentReview do
      let(:runner) { Core::Runner.new(reviews: ProtectMassAssignmentReview.new) }

      it "should protect mass assignment" do
        content =<<-EOF
        class User < ActiveRecord::Base
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:1 - protect mass assignment"
      end

      it "should not protect mass assignment if attr_accessible is used with arguments and user set config.active_record.whitelist_attributes" do
        content =<<-EOF
        module RailsBestPracticesCom
          class Application < Rails::Application
            config.active_record.whitelist_attributes = true
          end
        end
        EOF
        runner.prepare('config/application.rb', content)
        content =<<-EOF
        class User < ActiveRecord::Base
          attr_accessible :email, :password, :password_confirmation
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment if attr_accessible is used without arguments and user set config.active_record.whitelist_attributes" do
        content =<<-EOF
        module RailsBestPracticesCom
          class Application < Rails::Application
            config.active_record.whitelist_attributes = true
          end
        end
        EOF
        runner.prepare('config/application.rb', content)
        content =<<-EOF
        class User < ActiveRecord::Base
          attr_accessible
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment with attr_protected if user set config.active_record.whitelist_attributes" do
        content =<<-EOF
        module RailsBestPracticesCom
          class Application < Rails::Application
            config.active_record.whitelist_attributes = true
          end
        end
        EOF
        runner.prepare('config/application.rb', content)
        content =<<-EOF
        class User < ActiveRecord::Base
          attr_protected :role
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment if using devise" do
        content =<<-EOF
        class User < ActiveRecord::Base
          devise :database_authenticatable, :registerable, :confirmable, :recoverable, stretches: 20
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment if using authlogic with configuration" do
        content =<<-EOF
        class User < ActiveRecord::Base
          acts_as_authentic do |c|
            c.my_config_option = my_value
          end
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment if using authlogic without configuration" do
        content =<<-EOF
        class User < ActiveRecord::Base
          acts_as_authentic
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment if checking non ActiveRecord::Base inherited model" do
        content =<<-EOF
        class User < Person
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end

      it "should not protect mass assignment for strong_parameters" do
        content =<<-EOF
        class User < ActiveRecord::Base
          include ActiveModel::ForbiddenAttributesProtection
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
