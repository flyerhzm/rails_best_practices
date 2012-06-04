require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseObserverReview do
      let(:runner) { Core::Runner.new(prepares: Prepares::MailerPrepare.new, reviews: UseObserverReview.new) }

      before :each do
        content =<<-EOF
        class ProjectMailer < ActionMailer::Base
        end
        EOF
        runner.prepare('app/models/project_mailer.rb', content)
      end

      describe "rails2" do
        it "should use observer" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create :send_create_notification

            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.deliver_notification(self, member)
              end
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/models/project.rb:5 - use observer"
        end

        it "should not use observer without callback" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.deliver_notification(self, member)
              end
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(0).errors
        end

        it "should use observer with two after_create" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create :send_create_notification, :update_author

            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.deliver_notification(self, member)
              end
            end

            def update_author
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/models/project.rb:5 - use observer"
        end

        it "should not raise when initiate an object in callback" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create ProjectMailer.new
          end
          EOF
          lambda { runner.review('app/models/project.rb', content) }.should_not raise_error
        end
      end

      describe "rails3" do
        it "should use observer" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create :send_create_notification

            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.notification(self, member).deliver
              end
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/models/project.rb:5 - use observer"
        end

        it "should not use observer without callback" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.notification(self, member).deliver
              end
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(0).errors
        end

        it "should use observer with two after_create" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create :send_create_notification, :update_author

            private
            def send_create_notification
              self.members.each do |member|
                ProjectMailer.notification(self, member).deliver
              end
            end

            def update_author
            end
          end
          EOF
          runner.review('app/models/project.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/models/project.rb:5 - use observer"
        end

        it "should not raise when initiate an object in callback" do
          content =<<-EOF
          class Project < ActiveRecord::Base
            after_create ProjectMailer.new
          end
          EOF
          lambda { runner.review('app/models/project.rb', content) }.should_not raise_error
        end
      end
    end
  end
end
