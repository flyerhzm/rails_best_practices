# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe ReplaceInstanceVariableWithLocalVariableReview do
      let(:runner) { Core::Runner.new(reviews: ReplaceInstanceVariableWithLocalVariableReview.new) }

      it 'should replace instance variable with local varialbe' do
        content = <<-EOF
        <%= @post.title %>
        EOF
        runner.review('app/views/posts/_post.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/_post.html.erb:1 - replace instance variable with local variable')
      end

      it 'should replace instance variable with local varialbe in haml file' do
        content = <<~EOF
          = @post.title
        EOF
        runner.review('app/views/posts/_post.html.haml', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/_post.html.haml:1 - replace instance variable with local variable')
      end

      it 'should replace instance variable with local varialbe in slim file' do
        content = <<~EOF
          = @post.title
        EOF
        runner.review('app/views/posts/_post.html.slim', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/_post.html.slim:1 - replace instance variable with local variable')
      end

      it 'should not replace instance variable with local varialbe' do
        content = <<-EOF
        <%= post.title %>
        EOF
        runner.review('app/views/posts/_post.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: ReplaceInstanceVariableWithLocalVariableReview.new(ignored_files: /views\/posts/))
        content = <<-EOF
        <%= @post.title %>
        EOF
        runner.review('app/views/posts/_post.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
