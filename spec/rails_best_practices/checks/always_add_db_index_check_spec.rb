require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::AlwaysAddDbIndexCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::AlwaysAddDbIndexCheck.new)
  end

  it "should always add db index" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :post_id
          t.integer :user_id
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:5 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:6 - always add db index (comments => user_id)"
  end

  it "should always add db index with column has no id" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :position
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should always add db index with references" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.references :post
          t.references :user
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:5 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:6 - always add db index (comments => user_id)"
  end

  it "should always add db index with column" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.column :post_id, :integer
          t.column :user_id, :integer
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:5 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:6 - always add db index (comments => user_id)"
  end

  it "should not always add db index with add_index" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :post_id
          t.integer :user_id
        end

        add_index :comments, :post_id
        add_index :comments, :user_id
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index with add_index in another migration file" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :post_id
          t.integer :user_id
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    add_index_content = <<-EOF
    class AddIndexesToComments < ActiveRecord::Migration
      def self.up
        add_index :comments, :post_id
        add_index :comments, :user_id
      end
    end
    EOF
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090919130260_add_indexes_to_comments.rb', add_index_content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090919130260_add_indexes_to_comments.rb', add_index_content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index with add_index in another migration file and a migration between them" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :post_id
          t.integer :user_id
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    another_content = <<-EOF
    class Settings < ActiveRecord::Migration
      def self.my_escape(val)
      end

      def self.up
        add_column :settings, :groep, :string, :limit => 50
      end
    end
    EOF
    add_index_content = <<-EOF
    class AddIndexesToComments < ActiveRecord::Migration
      def self.up
        add_index :comments, :post_id
        add_index :comments, :user_id
      end
    end
    EOF
    @runner.check('db/migrate/20090918140258_create_comments.rb', content)
    @runner.check('db/migrate/20090918140259_settings.rb', another_content)
    @runner.check('db/migrate/20090919140260_add_indexes_to_comments.rb', add_index_content)
    @runner.check('db/migrate/20090918140258_create_comments.rb', content)
    @runner.check('db/migrate/20090918140259_settings.rb', another_content)
    @runner.check('db/migrate/20090919140260_add_indexes_to_comments.rb', add_index_content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should always add db index without error" do
    content = <<-EOF
    class AddIndexes < ActiveRecord::Migration
      def self.up
        [[:site_wide_admins, :admin_id, { :unique => true }],
         [:photos, [:target_id, :target_type, :type]],
         [:photos, [:target_id, :target_type, :parent_id, :is_avatar]],
         [:category_assignments, [:category_id, :sub_category_id, :target_id, :target_type]],
         [:network_connections, :user_id]].each do |args|
          add_index(*args) rescue say "Failed to add index"
        end
        # raise "abort migration"
      end

      def self.down
      end
    end
    EOF
    @runner.check('db/migrate/20091111113612_add_indexes.rb', content)
    @runner.check('db/migrate/20091111113612_add_indexes.rb', content)
    errors = @runner.errors
  end

  it "should always add db index without error 2" do
    content = <<-EOF
    class MoveCategoriesToProfileArea < ActiveRecord::Migration
      def self.up
        CategoryArea.update_all({:name => "Profile"}, ["name IN (?)", %w(UserSite UserProfile Site)])
      end

      def self.down
      end
    end
    EOF
    @runner.check('db/migrate/20090706091635_move_categories_to_profile_area.rb', content)
    @runner.check('db/migrate/20090706091635_move_categories_to_profile_area.rb', content)
    errors = @runner.errors
  end
  
  it "should always add db index without duplicate error outputs" do
    content = <<-EOF
    class AllTables < ActiveRecord::Migration
      def self.up
        create_table "ducks" do |t|
          t.column "registration", :string, :limit => 32
          t.column "description",  :string
        end

        create_table "lab_data" do |t|
          t.integer "input_biologist_id", :null => true
          t.integer "owner_biologist_id", :null => false
          t.column "remark",             :string,   :limit => 250
        end
      end
    end
    EOF
    @runner.check('db/migrate/20090204160203_all_tables.rb', content)
    @runner.check('db/migrate/20090204160203_all_tables.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/migrate/20090204160203_all_tables.rb:9 - always add db index (lab_data => input_biologist_id)"
    errors[1].to_s.should == "db/migrate/20090204160203_all_tables.rb:10 - always add db index (lab_data => owner_biologist_id)"
  end
  
  it "should not always add db index when table is created and droped" do
    content = <<-EOF
    class CreateComments < ActiveRecord::Migration
      def self.up
        create_table "comments", :force => true do |t|
          t.string :content
          t.integer :post_id
          t.integer :user_id
        end
      end

      def self.down
        drop_table "comments"
      end
    end
    EOF
    another_content = <<-EOF
    class DropComments < ActiveRecord::Migration
      def self.up
        drop_table "comments"
      end
      
      def self.down
      end
    end
    EOF
    @runner.check('db/migrate/20100118140258_create_comments.rb', content)
    @runner.check('db/migrate/20100118140259_drop_comments.rb', another_content)
    @runner.check('db/migrate/20100118140258_create_comments.rb', content)
    @runner.check('db/migrate/20100118140259_drop_comments.rb', another_content)
    errors = @runner.errors
    errors.should be_empty
  end
end
