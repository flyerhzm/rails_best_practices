require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::IsolateSeedDataCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::IsolateSeedDataCheck.new)
  end

  it "should isolate seed data" do
    content = <<-EOF
    class CreateRoles < ActiveRecord::Migration
      def self.up
        create_table "roles", :force => true do |t|
          t.string :name
        end

        ["admin", "author", "editor", "account"].each do |name|
          Role.create!(:name => name)
        end
      end

      def self.down
        drop_table "roles"
      end
    end
    EOF
    @runner.check('db/migrate/20090818130258_create_roles.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090818130258_create_roles.rb:8 - isolate seed data"
    errors.size.should == 1
  end
  
  it "should isolate seed data with new and save" do
    content = <<-EOF
    class CreateRoles < ActiveRecord::Migration
      def self.up
        create_table "roles", :force => true do |t|
          t.string :name
        end
  
        ["admin", "author", "editor", "account"].each do |name|
          role = Role.new(:name => name)
          role.save!
        end
      end
  
      def self.down
        drop_table "roles"
      end
    end
    EOF
    @runner.check('db/migrate/20090818130258_create_roles.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090818130258_create_roles.rb:9 - isolate seed data"
  end
  
  it "should not isolate seed data without data insert" do
    content = <<-EOF
    class CreateRoles < ActiveRecord::Migration
      def self.up
        create_table "roles", :force => true do |t|
          t.string :name
        end
      end
  
      def self.down
        drop_table "roles"
      end
    end
    EOF
    @runner.check('db/migrate/20090818130258_create_roles.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
