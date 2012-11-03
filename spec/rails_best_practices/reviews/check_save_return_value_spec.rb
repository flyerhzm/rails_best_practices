require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe CheckSaveReturnValueReview do
      let(:runner) { Core::Runner.new(reviews: CheckSaveReturnValueReview.new) }

      describe "check_save_return_value" do
        it "should warn you if you fail to check save return value" do
          content =<<-EOF
          def my_method
            post = Posts.new do |p|
              p.title = "foo"
            end
            post.save
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:5 - check 'save' return value or use 'save!'"
        end

        it "should allow save return value assigned to var" do
          content =<<-EOF
          def my_method
            post = Posts.new do |p|
              p.title = "foo"
            end
            check_this_later = post.save
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "should allow save return value used in if" do
          content =<<-EOF
          def my_method
            post = Posts.new do |p|
              p.title = "foo"
            end
            if post.save
              "OK"
            else
              raise "could not save"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "should allow save return value used in unless" do
          content =<<-EOF
          def my_method
            unless @post.save
              raise "could not save"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "should allow save return value used in unless with &&" do
          content =<<-EOF
          def my_method
            unless some_method(1) && other_method(2) && @post.save
              raise "could not save"
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "should allow save!" do
          content =<<-EOF
          def my_method
            post = Posts.new do |p|
              p.title = "foo"
            end
            post.save!
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "should warn you if you fail to check update_attributes return value" do
          content =<<-EOF
          def my_method
            @post.update_attributes params
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - check 'update_attributes' return value or use 'update_attributes!'"
        end

        it "should allow update_attributes if return value is checked" do
          content =<<-EOF
          def my_method
            @post.update_attributes(params) or raise "failed to save"
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(0).errors
        end

        it "is not clever enough to allow update_attributes if value is returned from method" do
          # This review is not clever enough to do a full liveness analysis
          # of whether the returned value is used in all cases.
          content =<<-EOF
          class PostsController
            def update
              @post = Post.find params(:id)
              if update_post
                redirect_to view_post_path post
              else
                raise "post not saved"
              end
            end

            def update_post
              @post.update_attributes(params)
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:12 - check 'update_attributes' return value or use 'update_attributes!'"
        end

        it "should warn you if you use create which is always unsafe" do
          content =<<-EOF
          def my_method
            if post = Post.create(params)
              # post may or may not be saved here!
              redirect_to view_post_path post
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - use 'create!' instead of 'create' as the latter may not always save"
        end

        it "should warn you if you use create with a block which is always unsafe" do
          content =<<-EOF
          def my_method
            post = Post.create do |p|
              p.title = 'new post'
            end
            if post
              # post may or may not be saved here!
              redirect_to view_post_path post
            end
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - use 'create!' instead of 'create' as the latter may not always save"
        end

        it "is not clever enough to ignore create called on non-model classes" do
          # I can't think of a reasonably local way to establish whether the receiver
          # of a 'create' call is a model class or not.
          # I suppose the review could monitor all model classes and build a list of model
          # class names in the app... TODO
          content =<<-EOF
          def my_method
            pk12 = OpenSSL::PKCS12.create(
              "", # password
              descr, # friendly name
              key,
              cert)
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - use 'create!' instead of 'create' as the latter may not always save"
        end
      end
    end
  end
end
