require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseObserverCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseObserverCheck.new)
  end

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
    @runner.check('app/models/project.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/models/project.rb:6 - use observer"
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
    @runner.check('app/models/project.rb', content)
    errors = @runner.errors
    errors.should be_empty
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
    @runner.check('app/models/project.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/models/project.rb:6 - use observer"
  end
end
