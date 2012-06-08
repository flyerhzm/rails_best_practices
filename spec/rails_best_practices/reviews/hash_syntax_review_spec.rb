require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe HashSyntaxReview do
      let(:runner) { Core::Runner.new(reviews: HashSyntaxReview.new) }

      it "should find 1.8 Hash with symbol" do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { :foo => :bar }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - change Hash Syntax to 1.9"
      end
      context "should find 1.8 Hash with string" do
        it "and report them with Report StringHashes Option" do
          runner = Core::Runner.new(reviews: HashSyntaxReview.new(report_string_hash: true))
          content =<<-EOF
          class User < ActiveRecord::Base
            CONST = { "foo" => "bar" }
          end
          EOF
          runner.review('app/models/user.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/models/user.rb:2 - change Hash Syntax to 1.9"
        end

        it "and not report them without Report StringHashes Option" do
          runner = Core::Runner.new(reviews: HashSyntaxReview.new(report_string_hash: false))
          content =<<-EOF
          class User < ActiveRecord::Base
            CONST = { "foo" => "bar" }
          end
          EOF
          runner.review('app/models/user.rb', content)
          runner.should have(0).errors
        end
      end
      it "should not alert on 1.9 Syntax" do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { foo: :bar }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
