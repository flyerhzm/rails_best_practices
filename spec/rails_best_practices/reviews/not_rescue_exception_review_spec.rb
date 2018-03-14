# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NotRescueExceptionReview do
      let(:runner) { Core::Runner.new(reviews: NotRescueExceptionReview.new) }

      describe 'not_rescue_exception' do
        it 'should not rescue exception in method rescue with named var' do
          content = <<-EOF
          def my_method
            do_something
          rescue Exception => e
            logger.error e
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:3 - Don't rescue Exception")
        end

        it 'should not rescue exception in method rescue without named var' do
          content = <<-EOF
          def my_method
            do_something
          rescue Exception
            logger.error $!
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:3 - Don't rescue Exception")
        end

        it 'should not rescue exception in block rescue with named var' do
          content = <<-EOF
          def my_method
            begin
              do_something
            rescue Exception => e
              logger.error e
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:4 - Don't rescue Exception")
        end

        it 'should not rescue exception in block rescue without named var' do
          content = <<-EOF
          def my_method
            begin
              do_something
            rescue Exception
              logger.error $!
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/helpers/posts_helper.rb:4 - Don't rescue Exception")
        end

        it 'should allow rescue implicit StandardError in block rescue without named var' do
          content = <<-EOF
          def my_method
            begin
              do_something
            rescue
              logger.error $!
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should allow rescue explicit StandardError in block rescue without named var' do
          content = <<-EOF
          def my_method
            begin
              do_something
            rescue StandardError
              logger.error $!
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should not check ignored files' do
          runner = Core::Runner.new(reviews: NotRescueExceptionReview.new(ignored_files: /posts_helper/))
          content = <<-EOF
          def my_method
            do_something
          rescue Exception => e
            logger.error e
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end
    end
  end
end
