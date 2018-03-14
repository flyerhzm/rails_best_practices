require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe MoveCodeIntoModelReview do
      let(:runner) { Core::Runner.new(reviews: MoveCodeIntoModelReview.new) }

      it 'should move code into model' do
        content = <<-EOF
        <% if current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user)) %>
          <%= link_to 'Edit this post', edit_post_url(@post) %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - move code into model (@post use_count > 2)')
      end

      it 'should move code into model with haml' do
        content = <<-EOF
- if current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user))
  = link_to 'Edit this post', edit_post_url(@post)
        EOF
        runner.review('app/views/posts/show.html.haml', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.haml:1 - move code into model (@post use_count > 2)')
      end

      it 'should move code into model with slim' do
        content = <<-EOF
- if current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user))
  = link_to 'Edit this post', edit_post_url(@post)
        EOF
        runner.review('app/views/posts/show.html.slim', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.slim:1 - move code into model (@post use_count > 2)')
      end

      it 'should move code into model with if in one line' do
        content = <<-EOF
        <%= link_to 'Edit this post', edit_post_url(@post) if current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user)) %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - move code into model (@post use_count > 2)')
      end

      it "should move code into model with '? :'" do
        content = <<-EOF
        <%= current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user)) ? link_to('Edit this post', edit_post_url(@post)) : '' %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - move code into model (@post use_count > 2)')
      end

      it 'should move code into model only review for current if conditional statement' do
        content = <<-EOF
        <% if @post.title %>
          <% if @post.user %>
            <% if @post.description %>
            <% end %>
          <% end %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not move code into model' do
        content = <<-EOF
        <% if @post.editable_by?(current_user) %>
          <%= link_to 'Edit this post', edit_post_url(@post) %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not move code into model for multiple calls on same variable node' do
        content = <<-EOF
        <% if !job.company.blank? && job.company.title? %>
        <% end %>
        EOF
        runner.review('app/views/jobs/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: MoveCodeIntoModelReview.new(ignored_files: /app\/views\/post/))
        content = <<-EOF
        <% if current_user && @post.user && (current_user == @post.user || @post.editors.include?(current_user)) %>
          <%= link_to 'Edit this post', edit_post_url(@post) %>
        <% end %>
        EOF
        runner.review('app/views/posts/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
