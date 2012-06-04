require 'spec_helper'

module RailsBestPractices
  module Lexicals
    describe RemoveTrailingWhitespaceCheck do
      let(:runner) { Core::Runner.new(lexicals: RemoveTrailingWhitespaceCheck.new) }

      it "should remove trailing whitespace" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
        end
        EOF
        content.gsub!("\n", "  \n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:1 - remove trailing whitespace"
      end

      it "should remove whitespace with third line" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
        end
        EOF
        content.gsub!("d\n", "d  \n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - remove trailing whitespace"
      end

      it "should not remove trailing whitespace" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
        end
        EOF
        runner.lexical('app/models/user.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
