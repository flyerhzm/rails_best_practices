require 'spec_helper'

describe RailsBestPractices::Checks::UseSayWithTimeInMigrationsCheck do
  before :each do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseSayWithTimeInMigrationsCheck.new)
  end

  it "should use say with time in migrations" do
    content =<<-EOF
    def self.up
      User.find_each do |user|
        user.first_name, user.last_name = user.full_name.split(' ')
        user.save
      end
    end
    EOF
    @runner.check('db/migrate/20101010080658_update_users.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors.size.should == 1
    errors[0].to_s.should == "db/migrate/20101010080658_update_users.rb:2 - use say with time in migrations"
  end

  it "should not use say with time in migrations" do
    content =<<-EOF
    def self.up
      say_with_time("Initialize first_name and last_name for users") do
        User.find_each do |user|
          user.first_name, user.last_name = user.full_name.split(' ')
          user.save
          say(user.id + " was updated.")
        end
      end
    end
    EOF
    @runner.check('db/migrate/20101010080658_update_users.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not use say with time when default migration message" do
    content =<<-EOF
    def self.up
      create_table :users do |t|
        t.string :login
        t.string :email
        t.timestamps
      end
    end
    EOF
    @runner.check('db/migrate/20101010080658_create_users.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
