require 'spec_helper'

module RailsBestPractices
  module Lexicals
    describe RemoveTabCheck do
      let(:runner) { Core::Runner.new(lexicals: RemoveTabCheck.new) }

      it "should remove tab" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
        end
        EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:1 - remove tab, use spaces instead"
      end

      it "should remove tab with third line" do
        content =<<-EOF
        class User < ActiveRecord::Base
          has_many :projects
  \t
        end
        EOF
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - remove tab, use spaces instead"
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
