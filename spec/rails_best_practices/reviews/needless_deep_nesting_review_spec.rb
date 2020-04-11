# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NeedlessDeepNestingReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      it 'needlesses deep nesting' do
        content = <<-EOF
        resources :posts do
          resources :comments do
            resources :favorites
          end
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('config/routes.rb:3 - needless deep nesting (nested_count > 2)')
      end

      it 'does not needless deep nesting for shallow' do
        content = <<-EOF
        resources :posts, shallow: true do
          resources :comments do
            resources :favorites
          end
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not needless deep nesting for shallow 4 levels' do
        content = <<-EOF
        resources :applications, shallow: true, only: [:index, :show, :create] do
          resources :events, only: [:index, :show, :create, :subscribe, :push] do
            resources :executions, only: [:index, :show] do
              resources :execution_statuses, only: :index
            end
          end
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'needlesses deep nesting with resource' do
        content = <<-EOF
        resources :posts do
          resources :comments do
            resource :vote
          end
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('config/routes.rb:3 - needless deep nesting (nested_count > 2)')
      end

      it 'needlesses deep nesting with block node' do
        content = <<-EOF
        resources :posts do
          resources :comments do
            resources :favorites
          end
          resources :votes
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('config/routes.rb:3 - needless deep nesting (nested_count > 2)')
      end

      it 'noes needless deep nesting' do
        content = <<-EOF
        resources :posts do
          resources :comments
          resources :votes
        end

        resources :comments do
          resources :favorites
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: %r{config/routes}))
        content = <<-EOF
          map.resources :posts do |post|
            post.resources :comments do |comment|
              comment.resources :favorites
            end
          end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
