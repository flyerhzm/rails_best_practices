require 'spec_helper'

module RailsBestPractices
  module Lexicals
    describe HashSyntaxCheck do
      let(:runner) { Core::Runner.new(:lexicals => HashSyntaxCheck.new) }

      it "should find 1.8 Hash" do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { :foo => :bar }
        end
        EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:2 - change Hash Syntax to 1.9"
      end

      it "should remove tab with third line" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
          CONST = { :foo => :bar }
        end
        EOF
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - change Hash Syntax to 1.9"
      end

      it "should not alert on 1.9 Syntax" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
          CONST = { foo: :bar }
        end
        EOF
        runner.lexical('app/models/user.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
