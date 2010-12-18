require 'spec_helper'

describe RailsBestPractices::Checks::AlwaysAddDbIndexCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::AlwaysAddDbIndexCheck.new)
  end

  it "should always add db index" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "comments", :force => true do |t|
        t.string "content"
        t.integer "post_id"
        t.integer "user_id"
      end
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/schema.rb:2 - always add db index (comments => [post_id])"
    errors[1].to_s.should == "db/schema.rb:2 - always add db index (comments => [user_id])"
  end

  it "should always add db index with polymorphic foreign key" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "versions", :force => true do |t|
        t.integer  "versioned_id"
        t.string   "versioned_type"
        t.string   "tag"
      end
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/schema.rb:2 - always add db index (versions => [versioned_id, versioned_type])"
  end

  it "should always add db index with polymorphic foreign key and _type is defined before _id" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "versions", :force => true do |t|
        t.string   "versioned_type"
        t.integer  "versioned_id"
        t.string   "tag"
      end
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors.size.should == 1
    errors[0].to_s.should == "db/schema.rb:2 - always add db index (versions => [versioned_id, versioned_type])"
  end

  it "should always add db index with single index, but without polymorphic foreign key" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "taggings", :force => true do |t|
        t.integer  "tag_id"
        t.integer  "taggable_id"
        t.string   "taggable_type"
      end

      add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/schema.rb:2 - always add db index (taggings => [taggable_id, taggable_type])"
  end

  it "should always add db index with polymorphic foreign key, but without single index" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "taggings", :force => true do |t|
        t.integer  "tag_id"
        t.integer  "taggable_id"
        t.string   "taggable_type"
      end

      add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/schema.rb:2 - always add db index (taggings => [tag_id])"
  end

  it "should not always add db index with column has no id" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "comments", :force => true do |t|
        t.string "content"
        t.integer "position"
      end
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index with add_index" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "comments", :force => true do |t|
        t.string "content"
        t.integer "post_id"
        t.integer "user_id"
      end

      add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
      add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index with only _type column" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "versions", :force => true do |t|
        t.string   "versioned_type"
      end
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index with multi-column index" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "versions", :force => true do |t|
        t.integer  "versioned_id"
        t.string   "versioned_type"
        t.string   "tag"
      end

      add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not always add db index if there is an index contains more columns" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "taggings", :force => true do |t|
        t.integer  "taggable_id"
        t.string   "taggable_type"
        t.string   "context"
      end

      add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
    end
    EOF
    @runner.review('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
