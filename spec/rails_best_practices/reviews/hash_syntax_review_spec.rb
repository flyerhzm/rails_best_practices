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

      it "should find 1.8 Hash with symbol" do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { "foo" => "bar" }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - change Hash Syntax to 1.9"
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

      it "should only check symbol syntax" do
        runner = Core::Runner.new(reviews: HashSyntaxReview.new(only_symbol: true))
        content =<<-EOF
        class User < ActiveRecord::Base
          SYMBOL_CONST = { :foo => :bar }
          STRING_CONST = { "foo" => "bar" }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - change Hash Syntax to 1.9"
      end

      it "should only check string syntax" do
        runner = Core::Runner.new(reviews: HashSyntaxReview.new(only_string: true))
        content =<<-EOF
        class User < ActiveRecord::Base
          SYMBOL_CONST = { :foo => :bar }
          STRING_CONST = { "foo" => "bar" }
        end
        EOF
        runner.review('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - change Hash Syntax to 1.9"
      end

      it "should ignore haml_out" do
        content =<<-EOF

%div{ class: "foo1" }
.div{ class: "foo2" }
#div{ class: "foo3" }

        EOF
        runner.review('app/views/files/show.html.haml', content)
        runner.should have(0).errors
      end
    end
  end
end
