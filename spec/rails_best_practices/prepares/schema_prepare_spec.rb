require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe SchemaPrepare do
      let(:runner) { Core::Runner.new(prepares: SchemaPrepare.new) }

      it "should parse model attributes" do
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
        runner.prepare("db/schema.rb", content)
        model_attributes = Prepares.model_attributes
        model_attributes.get_attribute_type("Post", "title").should == "string"
        model_attributes.get_attribute_type("Post", "body").should == "text"
        model_attributes.get_attribute_type("Post", "created_at").should == "datetime"
        model_attributes.get_attribute_type("Post", "user_id").should == "integer"
        model_attributes.get_attribute_type("Post", "comments_count").should == "integer"
        model_attributes.get_attribute_type("Post", "published").should == "boolean"
      end
    end
  end
end
