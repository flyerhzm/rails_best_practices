# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe MoveCodeIntoHelperReview do
      let(:runner) { Core::Runner.new(reviews: MoveCodeIntoHelperReview.new('array_count' => 2)) }

      it 'should move code into helper' do
        content = <<-EOF
        <%= select_tag :state, options_for_select( [[t(:draft), "draft"],
                                                    [t(:published), "published"]],
                                                   params[:default_state] ) %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - move code into helper (array_count >= 2)')
      end

      it 'should not move code into helper with simple arguments' do
        content = <<-EOF
        <%= select_tag :state, options_for_select( Post.STATES ) %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: MoveCodeIntoControllerReview.new('array_count' => 2, 'ignored_files' => /app\/views\/post/))
        content = <<-EOF
        <%= select_tag :state, options_for_select( [[t(:draft), "draft"],
                                                    [t(:published), "published"]],
                                                   params[:default_state] ) %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
