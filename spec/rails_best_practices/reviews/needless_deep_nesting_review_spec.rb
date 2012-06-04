require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NeedlessDeepNestingReview do
      let(:runner) { Core::Runner.new(reviews: NeedlessDeepNestingReview.new) }

      describe "rails2" do
        it "should needless deep nesting" do
          content = <<-EOF
          map.resources :posts do |post|
            post.resources :comments do |comment|
              comment.resources :favorites
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should not needless deep nesting for shallow" do
          content = <<-EOF
          map.resources :posts, shallow: true do |post|
            post.resources :comments do |comment|
              comment.resources :favorites
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end

        it "should needless deep nesting with resource" do
          content = <<-EOF
          map.resources :posts do |post|
            post.resources :comments do |comment|
              comment.resource :vote
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should needless deep nesting with block node" do
          content = <<-EOF
          map.resources :posts do |post|
            post.resources :comments do |comment|
              comment.resources :favorites
            end
            post.resources :votes
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should no needless deep nesting" do
          content = <<-EOF
          map.resources :posts do |post|
            post.resources :comments
          end

          map.resources :comments do |comment|
            comment.resources :favorites
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end

        it "should no needless deep nesting with block node" do
          content = <<-EOF
          map.resources :comments do |comment|
            comment.resources :favorites
            comment.resources :votes
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end
      end

      describe "rails3" do
        it "should needless deep nesting" do
          content = <<-EOF
          resources :posts do
            resources :comments do
              resources :favorites
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should not needless deep nesting for shallow" do
          content = <<-EOF
          resources :posts, shallow: true do
            resources :comments do
              resources :favorites
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end

        it "should not needless deep nesting for shallow 4 levels" do
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
          runner.should have(0).errors
        end

        it "should needless deep nesting with resource" do
          content = <<-EOF
          resources :posts do
            resources :comments do
              resource :vote
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should needless deep nesting with block node" do
          content = <<-EOF
          resources :posts do
            resources :comments do
              resources :favorites
            end
            resources :votes
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
        end

        it "should no needless deep nesting" do
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
          runner.should have(0).errors
        end
      end
    end
  end
end
