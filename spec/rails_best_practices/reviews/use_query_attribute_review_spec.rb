# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseQueryAttributeReview do
      let(:runner) { Core::Runner.new(prepares: [Prepares::ModelPrepare.new, Prepares::SchemaPrepare.new], reviews: UseQueryAttributeReview.new) }

      before :each do
        content = <<-EOF
        class User < ActiveRecord::Base
          has_many :projects
          belongs_to :location
          has_one :phone

          belongs_to :category, class_name: 'IssueCategory', foreign_key: 'category_id'
        end
        EOF
        runner.prepare('app/models/user.rb', content)

        content = <<-EOF
        ActiveRecord::Schema.define(version: 20110216150853) do
          create_table "users", force => true do |t|
            t.string :login
            t.integer :age
          end
        end
        EOF
        runner.prepare('db/schema.rb', content)
      end

      it 'should use query attribute by blank call' do
        content = <<-EOF
        <% if @user.login.blank? %>
          <%= link_to 'login', new_session_path %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute by blank call with if in one line' do
        content = <<-EOF
        <%= link_to 'login', new_session_path if @user.login.blank? %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it "should use query attribute by blank call with '? :'" do
        content = <<-EOF
        <%= @user.login.blank? ? link_to('login', new_session_path) : '' %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute by comparing empty string' do
        content = <<-EOF
        <% if @user.login == "" %>
          <%= link_to 'login', new_session_path %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute by nil call' do
        content = <<-EOF
        <% if @user.login.nil? %>
          <%= link_to 'login', new_session_path %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute by present call' do
        content = <<-EOF
        <% if @user.login.present? %>
          <%= @user.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute within and conditions' do
        content = <<-EOF
        <% if @user.active? && @user.login.present? %>
          <%= @user.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should use query attribute within or conditions' do
        content = <<-EOF
        <% if @user.active? or @user.login != "" %>
          <%= @user.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/views/users/show.html.erb:1 - use query attribute (@user.login?)')
      end

      it 'should not use query attribute' do
        content = <<-EOF
        <% if @user.login? %>
          <%= @user.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not use query attribute for number' do
        content =<<-EOF
        <% unless @user.age.blank? %>
          <%= @user.age %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not review for pluralize attribute' do
        content = <<-EOF
        <% if @user.roles.blank? %>
          <%= @user.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not review non model class' do
        content = <<-EOF
        <% if @person.login.present? %>
          <%= @person.login %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      context 'association' do
        it 'should not review belongs_to association' do
          content = <<-EOF
          <% if @user.location.present? %>
            <%= @user.location.name %>
          <% end %>
          EOF
          runner.review('app/views/users/show.html.erb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should not review belongs_to category' do
          content = <<-EOF
          <% if @user.category.present? %>
            <%= @user.category.name %>
          <% end %>
          EOF
          runner.review('app/views/users/show.html.erb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should not review has_one association' do
          content = <<-EOF
          <% if @user.phone.present? %>
            <%= @user.phone.number %>
          <% end %>
          EOF
          runner.review('app/views/users/show.html.erb', content)
          expect(runner.errors.size).to eq(0)
        end

        it 'should not review has_many association' do
          content = <<-EOF
          <% if @user.projects.present? %>
            <%= @user.projects.first.name %>
          <% end %>
          EOF
          runner.review('app/views/users/show.html.erb', content)
          expect(runner.errors.size).to eq(0)
        end
      end

      it 'should not review for class method' do
        content = <<-EOF
        <% if User.name.present? %>
          <%= User.name %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not review for non attribute call' do
        content = <<-EOF
        if @user.login(false).nil?
          puts @user.login(false)
        end
        EOF
        runner.review('app/models/users_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not raise error for common conditional statement' do
        content = <<-EOF
        if voteable.is_a? Answer
          puts voteable.title
        end
        EOF
        expect { runner.review('app/models/users_controller.rb', content) }.not_to raise_error
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(prepares: [Prepares::ModelPrepare.new, Prepares::SchemaPrepare.new],
                                  reviews: UseQueryAttributeReview.new(ignored_files: /users\/show/))
        content = <<-EOF
        <% if @user.login.blank? %>
          <%= link_to 'login', new_session_path %>
        <% end %>
        EOF
        runner.review('app/views/users/show.html.erb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
