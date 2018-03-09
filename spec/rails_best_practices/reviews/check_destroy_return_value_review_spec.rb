require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe CheckDestroyReturnValueReview do
      let(:runner) { Core::Runner.new(reviews: CheckDestroyReturnValueReview.new) }

      describe 'check_destroy_return_value' do
        it 'should warn you if you fail to check the destroy return value' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            post.destroy
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:5 - check 'destroy' return value or use 'destroy!'")
        end

        it 'should allow destroy return value if assigned to a var' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            check_this_later = post.destroy
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in if' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            if post.destroy
              "OK"
            else
              raise "could not delete"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in elsif' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            if current_user
              "YES"
            elsif post.destroy
              "OK"
            else
              raise "could not delete"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in unless' do
          content = <<-EOF
          def my_method
            unless @post.destroy
              raise "could not destroy"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in if_mod' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            "OK" if post.destroy
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in unless_mod' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            "NO" unless post.destroy
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy return value used in unless with &&' do
          content = <<-EOF
          def my_method
            unless some_method(1) && other_method(2) && @post.destroy
              raise "could not destroy"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow destroy!' do
          content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            post.destroy!
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: CheckDestroyReturnValueReview.new(ignored_files: /helpers/))
        content = <<-EOF
          def my_method
            post = Posts.create do |p|
              p.title = "foo"
            end
            post.destroy
          end
        EOF
        runner.review('app/helpers/posts_helper.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
