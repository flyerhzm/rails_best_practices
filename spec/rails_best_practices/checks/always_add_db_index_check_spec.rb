require File.join(File.dirname(__FILE__) + '/../../spec_helper')

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
    @runner.check('db/schema.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "db/schema.rb:4 - always add db index (comments => post_id)"
    errors[1].to_s.should == "db/schema.rb:5 - always add db index (comments => user_id)"
  end
  
  it "should always add db index with column has no id" do
    content = <<-EOF
    ActiveRecord::Schema.define(:version => 20100603080629) do
      create_table "comments", :force => true do |t|
        t.string "content"
        t.integer "position"
      end
    end
    EOF
    @runner.check('db/schema.rb', content)
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
    @runner.check('db/schema.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
