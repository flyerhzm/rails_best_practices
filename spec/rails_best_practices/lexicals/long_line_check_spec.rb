# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Lexicals
    describe LongLineCheck do
      it 'should find long lines' do
        runner = Core::Runner.new(lexicals: LongLineCheck.new)
        content = <<-EOF
class User < ActiveRecord::Base
# 81 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 80 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
end
EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/models/user.rb:3 - line is longer than 80 characters (81 characters)')
      end
      it 'should find long lines with own max size' do
        runner = Core::Runner.new(lexicals: LongLineCheck.new('max_line_length' => 90))
        content = <<-EOF
class User < ActiveRecord::Base
# 91 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# 90 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
end
EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/models/user.rb:3 - line is longer than 90 characters (91 characters)')
      end
      it 'should not check non .rb files' do
        runner = Core::Runner.new(lexicals: LongLineCheck.new)
        content = "
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"
        runner.lexical('app/views/users/index.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
      it 'should not check ignored files' do
        runner = Core::Runner.new(lexicals: LongLineCheck.new(max_line_length: 80, ignored_files: /user/))
        content = <<-EOF
class User < ActiveRecord::Base
# 81 Chars
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
end
        EOF
        content.gsub!("\n", "\t\n")
        runner.lexical('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
