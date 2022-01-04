# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe HelperPrepare do
      let(:runner) { Core::Runner.new(prepares: described_class.new) }

      context 'methods' do
        it 'parses helper methods' do
          content = <<-EOF
          module PostsHelper
            def used; end
            def unused; end
          end
          EOF
          runner.prepare('app/helpers/posts_helper.rb', content)
          methods = Prepares.helper_methods
          expect(methods.get_methods('PostsHelper').map(&:method_name)).to eq(%w[used unused])
        end

        it 'parses helpers' do
          content = <<-EOF
          module PostsHelper
          end
          EOF
          runner.prepare('app/helpers/posts_helper.rb', content)
          content = <<-EOF
          module Admin::UsersHelper
          end
          EOF
          runner.prepare('app/helpers/users_helper.rb', content)
          content = <<-EOF
          module Admin
            module BaseHelper
            end
          end
          EOF
          runner.prepare('app/helpers/base_helper.rb', content)
          helpers = Prepares.helpers
          expect(helpers.map(&:to_s)).to eq(%w[PostsHelper Admin::UsersHelper Admin Admin::BaseHelper])
        end
      end
    end
  end
end
