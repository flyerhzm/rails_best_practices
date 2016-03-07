require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe AlwaysAddDbIndexReview do
      let(:runner) { Core::Runner.new(reviews: AlwaysAddDbIndexReview.new) }

      it "should always add db index" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "post_id"
            t.integer "user_id"
          end
          create_table "posts", force: true do |t|
          end
          create_table "users", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(2)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (comments => [post_id])")
        expect(runner.errors[1].to_s).to eq("db/schema.rb:2 - always add db index (comments => [user_id])")
      end

      it "should always add db index with polymorphic foreign key" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "versions", force: true do |t|
            t.integer  "versioned_id"
            t.string   "versioned_type"
            t.string   "tag"
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (versions => [versioned_id, versioned_type])")
      end

      it "should always add db index with polymorphic foreign key and _type is defined before _id" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "versions", force: true do |t|
            t.string   "versioned_type"
            t.integer  "versioned_id"
            t.string   "tag"
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (versions => [versioned_id, versioned_type])")
      end

      it "should always add db index with single index, but without polymorphic foreign key" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "taggings", force: true do |t|
            t.integer  "tag_id"
            t.integer  "taggable_id"
            t.string   "taggable_type"
          end
          create_table "tags", force: true do |t|
          end

          add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (taggings => [taggable_id, taggable_type])")
      end

      it "should always add db index with polymorphic foreign key, but without single index" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "taggings", force: true do |t|
            t.integer  "tag_id"
            t.integer  "taggable_id"
            t.string   "taggable_type"
          end
          create_table "tags", force: true do |t|
          end

          add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (taggings => [tag_id])")
      end

      it "should always add db index only _id without non related _type column" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "websites", force: true do |t|
            t.integer  "user_id"
            t.string   "icon_file_name"
            t.integer  "icon_file_size"
            t.string   "icon_content_type"
          end
          create_table "users", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (websites => [user_id])")
      end

      it "should not always add db index with column has no id" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "position"
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index with add_index" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "post_id"
            t.integer "user_id"
          end
          create_table "posts", force: true do |t|
          end
          create_table "users", force: true do |t|
          end

          add_index "comments", ["post_id"], name: "index_comments_on_post_id"
          add_index "comments", ["user_id"], name: "index_comments_on_user_id"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index with t.index" do
        # e.g. schema_plus creates indices like this https://github.com/lomba/schema_plus
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "post_id"
            t.index ["post_id"], :name => "index_comments_on_post_id"
          end
          create_table "posts", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index with only _type column" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "versions", force: true do |t|
            t.string   "versioned_type"
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index with multi-column index" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "versions", force: true do |t|
            t.integer  "versioned_id"
            t.string   "versioned_type"
            t.string   "tag"
          end

          add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index if there is an index contains more columns" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "taggings", force: true do |t|
            t.integer  "taggable_id"
            t.string   "taggable_type"
            t.string   "context"
          end

          add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index if two indexes for polymorphic association" do
        content =<<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "taggings", force: true do |t|
            t.integer "tagger_id"
            t.string "tagger_type"
            t.datetime "created_at"
          end

          add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id"
          add_index "taggings", ["tagger_type"], name: "index_taggings_on_tagger_type"
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not always add db index if table does not exist" do
        content =<<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.integer "post_id"
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should always add db index if association_name is different to foreign_key" do
        content =<<-EOF
        class Comment < ActiveRecord::Base
          belongs_to :commentor, class_name: "User"
        end
        EOF
        runner.prepare('app/models/comment.rb', content)
        content =<<-EOF
        class User < ActiveRecord::Base
        end
        EOF
        runner.prepare('app/models/user.rb', content)
        content =<<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.integer "commentor_id"
          end
          create_table "users", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (comments => [commentor_id])")
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(reviews: AlwaysAddDbIndexReview.new(ignored_files: /db\/schema/))
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "post_id"
            t.integer "user_id"
          end
          create_table "posts", force: true do |t|
          end
          create_table "users", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should detect index option in column creation" do
        content = <<-EOF
        ActiveRecord::Schema.define(version: 20100603080629) do
          create_table "comments", force: true do |t|
            t.string "content"
            t.integer "post_id", index: true
            t.string "user_id", index: { unique: true }
            t.integer "image_id", index: false
            t.integer "link_id"
          end
          create_table "posts", force: true do |t|
          end
          create_table "users", id: :string, force: true do |t|
          end
          create_table "images", force: true do |t|
          end
          create_table "links", force: true do |t|
          end
        end
        EOF
        runner.review('db/schema.rb', content)
        runner.after_review
        expect(runner.errors.size).to eq(2)
        expect(runner.errors[0].to_s).to eq("db/schema.rb:2 - always add db index (comments => [image_id])")
        expect(runner.errors[1].to_s).to eq("db/schema.rb:2 - always add db index (comments => [link_id])")
      end
    end
  end
end
