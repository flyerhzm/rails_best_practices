# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe SimplifyRenderInControllersReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      it 'simplifies render action view' do
        content = <<-EOF
        def edit
          render action: :edit
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/controllers/posts_controller.rb:2 - simplify render in controllers')
      end

      it "simplifies render actions's template" do
        content = <<-EOF
        def edit
          render template: 'books/edit'
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/controllers/posts_controller.rb:2 - simplify render in controllers')
      end

      it 'simplifies render an arbitrary file' do
        content = <<-EOF
        def edit
          render file: '/path/to/rails/app/views/books/edit'
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/controllers/posts_controller.rb:2 - simplify render in controllers')
      end

      it 'does not simplify render action view' do
        content = <<-EOF
        render :edit
        EOF
        runner.review('app/controllers/posts_controller', content)
        expect(runner.errors.size).to eq(0)
      end

      it "does not simplify render actions's template" do
        content = <<-EOF
        def edit
          render 'books/edit'
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not simplify render an arbitrary file' do
        content = <<-EOF
        def edit
          render '/path/to/rails/app/views/books/edit'
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: /posts_controller/))
        content = <<-EOF
        def edit
          render action: :edit
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
