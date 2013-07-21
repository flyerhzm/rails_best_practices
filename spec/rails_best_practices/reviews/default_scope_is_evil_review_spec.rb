require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe DefaultScopeIsEvilReview do
      let(:runner) { Core::Runner.new(reviews: DefaultScopeIsEvilReview.new) }

      it "should detect default_scope with -> syntax" do
        content = <<-EOF
        class User < ActiveRecord::Base
          default_scope -> { order('created_at desc') }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - default_scope is evil"
      end

      it "should detect default_scope with old syntax" do
        content = <<-EOF
        class User < ActiveRecord::Base
          default_scope order('created_at desc')
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - default_scope is evil"
      end

      it "should not detect default_scope" do
        content = <<-EOF
        class User < ActiveRecord::Base
          scope :default, -> { order('created_at desc') }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
