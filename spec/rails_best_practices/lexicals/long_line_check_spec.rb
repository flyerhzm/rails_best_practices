require 'spec_helper'

module RailsBestPractices
  module Lexicals
    describe LongLineCheck do

      it "should find long lines" do
        runner = Core::Runner.new(lexicals: LongLineCheck.new)
        content =<<-EOF
class User < ActiveRecord::Base
# 81 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 80 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
end
EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - line is longer than 80 characters (81 characters)"
      end
      it "should find long lines with own max size" do
        runner = Core::Runner.new(lexicals: LongLineCheck.new('max_line_length' => 90))
        content =<<-EOF
class User < ActiveRecord::Base
# 91 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 90 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
end
EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/models/user.rb:3 - line is longer than 90 characters (91 characters)"
      end
      it "should not check non .rb files" do
        runner = Core::Runner.new(lexicals: LongLineCheck.new)
        content = "
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"
        runner.lexical('app/views/users/index.html.erb', content)
        runner.should have(0).errors
      end
    end
  end
end
