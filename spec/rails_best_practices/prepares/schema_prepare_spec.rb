# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe SchemaPrepare do
      let(:runner) { Core::Runner.new(prepares: SchemaPrepare.new) }

      it 'should parse model attributes' do
        content =<<-EOF
        ActiveRecord::Schema.define(version: 20110319172136) do
          create_table "posts", force: true do |t|
            t.string   "title"
            t.text     "body",           limit: 16777215
            t.datetime "created_at"
            t.integer  "user_id"
            t.integer  "comments_count",                     default: 0
            t.boolean  "published",                          default: false, null: false
          end
        end
        EOF
        runner.prepare('db/schema.rb', content)
        model_attributes = Prepares.model_attributes
        expect(model_attributes.get_attribute_type('Post', 'title')).to eq('string')
        expect(model_attributes.get_attribute_type('Post', 'body')).to eq('text')
        expect(model_attributes.get_attribute_type('Post', 'created_at')).to eq('datetime')
        expect(model_attributes.get_attribute_type('Post', 'user_id')).to eq('integer')
        expect(model_attributes.get_attribute_type('Post', 'comments_count')).to eq('integer')
        expect(model_attributes.get_attribute_type('Post', 'published')).to eq('boolean')
      end
    end
  end
end
