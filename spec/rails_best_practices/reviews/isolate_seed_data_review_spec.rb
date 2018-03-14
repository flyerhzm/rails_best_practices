# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe IsolateSeedDataReview do
      let(:runner) { Core::Runner.new(reviews: IsolateSeedDataReview.new) }

      context 'create' do
        it 'should isolate seed data' do
          content = <<-EOF
          class CreateRoles < ActiveRecord::Migration
            def self.up
              create_table "roles", force: true do |t|
                t.string :name
              end

              ["admin", "author", "editor", "account"].each do |name|
                Role.create!(name: name)
              end
            end

            def self.down
              drop_table "roles"
            end
          end
          EOF
          runner.review('db/migrate/20090818130258_create_roles.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('db/migrate/20090818130258_create_roles.rb:8 - isolate seed data')
        end
      end

      context 'new and save' do
        it 'should isolate seed data for local variable' do
          content = <<-EOF
          class CreateRoles < ActiveRecord::Migration
            def self.up
              create_table "roles", force: true do |t|
                t.string :name
              end

              ["admin", "author", "editor", "account"].each do |name|
                role = Role.new(name: name)
                role.save!
              end
            end

            def self.down
              drop_table "roles"
            end
          end
          EOF
          runner.review('db/migrate/20090818130258_create_roles.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('db/migrate/20090818130258_create_roles.rb:9 - isolate seed data')
        end

        it 'should isolate seed data for instance variable' do
          content = <<-EOF
          class CreateRoles < ActiveRecord::Migration
            def self.up
              create_table "roles", force: true do |t|
                t.string :name
              end

              ["admin", "author", "editor", "account"].each do |name|
                @role = Role.new(name: name)
                @role.save!
              end
            end

            def self.down
              drop_table "roles"
            end
          end
          EOF
          runner.review('db/migrate/20090818130258_create_roles.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('db/migrate/20090818130258_create_roles.rb:9 - isolate seed data')
        end
      end

      it 'should not isolate seed data without data insert' do
        content = <<-EOF
        class CreateRoles < ActiveRecord::Migration
          def self.up
            create_table "roles", force: true do |t|
              t.string :name
            end
          end

          def self.down
            drop_table "roles"
          end
        end
        EOF
        runner.review('db/migrate/20090818130258_create_roles.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: IsolateSeedDataReview.new(ignored_files: /create_roles/))
        content = <<-EOF
          class CreateRoles < ActiveRecord::Migration
            def self.up
              create_table "roles", force: true do |t|
                t.string :name
              end

              ["admin", "author", "editor", "account"].each do |name|
                Role.create!(name: name)
              end
            end

            def self.down
              drop_table "roles"
            end
          end
        EOF
        runner.review('db/migrate/20090818130258_create_roles.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
