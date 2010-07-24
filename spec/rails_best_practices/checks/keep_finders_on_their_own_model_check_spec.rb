require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::KeepFindersOnTheirOwnModelCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::KeepFindersOnTheirOwnModelCheck.new)
  end

  it "should keep finders on thier own model" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def find_valid_comments
        self.comment.find(:all, :conditions => { :is_spam => false }, 
                                :limit => 10)
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/models/post.rb:5 - keep finders on their own model"
  end

  it "should keep finders on thier own model with all method" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def find_valid_comments
        self.comment.all(:conditions => { :is_spam => false },
                         :limit => 10)
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/models/post.rb:5 - keep finders on their own model"
  end

  it "should not keep finders on thier own model with self finder" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def find_valid_comments
        self.find(:all, :conditions => { :is_spam => false }, 
                                :limit => 10)
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not keep finders on thier own model with own finder" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def find_valid_comments
        Post.find(:all, :conditions => { :is_spam => false }, 
                                :limit => 10)
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not keep finders on their own model without finder" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def find_valid_comments
        self.comments.destroy_all
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not keep finders on their own model with ruby Array#find" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      has_many :comments

      def active_comments
        self.comments.find {|comment| comment.status == 'active'}
      end
    end
    EOF
    @runner.check('app/models/post.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
