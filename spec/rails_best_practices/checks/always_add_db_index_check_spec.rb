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
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => user_id)"
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
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => user_id)"
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
    errors[0].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/migrate/20090918130258_create_comments.rb:2 - always add db index (comments => user_id)"
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
    @runner.check('db/migrate/20090919130258_add_indexes_to_comments.rb', add_index_content)
    @runner.check('db/migrate/20090918130258_create_comments.rb', content)
    @runner.check('db/migrate/20090919130258_add_indexes_to_comments.rb', add_index_content)
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
end
