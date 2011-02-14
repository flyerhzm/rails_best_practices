require 'spec_helper'

describe RailsBestPractices::Reviews::IsolateSeedDataReview do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(:reviews => RailsBestPractices::Reviews::IsolateSeedDataReview.new)
  end

  context "create" do
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
      @runner.review('db/migrate/20090818130258_create_roles.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "db/migrate/20090818130258_create_roles.rb:8 - isolate seed data"
      errors.size.should == 1
    end
  end

  context "new and save" do
    it "should isolate seed data for local variable" do
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
      @runner.review('db/migrate/20090818130258_create_roles.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "db/migrate/20090818130258_create_roles.rb:9 - isolate seed data"
    end

    it "should isolate seed data for instance variable" do
      content = <<-EOF
      class CreateRoles < ActiveRecord::Migration
        def self.up
          create_table "roles", :force => true do |t|
            t.string :name
          end

          ["admin", "author", "editor", "account"].each do |name|
            @role = Role.new(:name => name)
            @role.save!
          end
        end

        def self.down
          drop_table "roles"
        end
      end
      EOF
      @runner.review('db/migrate/20090818130258_create_roles.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "db/migrate/20090818130258_create_roles.rb:9 - isolate seed data"
    end
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
    @runner.review('db/migrate/20090818130258_create_roles.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
