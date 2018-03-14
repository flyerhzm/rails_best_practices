# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe HashSyntaxReview do
      let(:runner) { Core::Runner.new(reviews: HashSyntaxReview.new) }

      it 'should find 1.8 Hash with symbol' do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { :foo => :bar }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/models/user.rb:2 - change Hash Syntax to 1.9')
      end

      it 'should not find 1.8 Hash with string' do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { "foo" => "bar" }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not alert on 1.9 Syntax' do
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { foo: :bar }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should ignore haml_out' do
        content =<<-EOF
%div{ class: "foo1" }
.div{ class: "foo2" }
#div{ class: "foo3" }
        EOF
        runner.review('app/views/files/show.html.haml', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not consider hash with array key' do
        content =<<-EOF
        transition [:unverified, :verified] => :deleted
        EOF
        runner.review('app/models/post.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not consider hash with charaters not valid for symbol' do
        content =<<-EOF
        receiver.stub(:` => 'Error')
        EOF
        runner.review('app/models/post.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: HashSyntaxReview.new(ignored_files: /user/))
        content =<<-EOF
        class User < ActiveRecord::Base
          CONST = { :foo => :bar }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
