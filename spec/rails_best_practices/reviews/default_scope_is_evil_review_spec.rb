# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe DefaultScopeIsEvilReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      it 'detects default_scope with -> syntax' do
        content = <<-EOF
        class User < ActiveRecord::Base
          default_scope -> { order('created_at desc') }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/models/user.rb:2 - default_scope is evil')
      end

      it 'detects default_scope with old syntax' do
        content = <<-EOF
        class User < ActiveRecord::Base
          default_scope order('created_at desc')
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/models/user.rb:2 - default_scope is evil')
      end

      it 'does not detect default_scope' do
        content = <<-EOF
        class User < ActiveRecord::Base
          scope :default, -> { order('created_at desc') }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: /user/))
        content = <<-EOF
        class User < ActiveRecord::Base
          default_scope -> { order('created_at desc') }
        end
        EOF
        runner.review('app/models/user.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
