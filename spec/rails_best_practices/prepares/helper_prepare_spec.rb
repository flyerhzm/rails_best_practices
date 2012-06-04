require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe HelperPrepare do
      let(:runner) { Core::Runner.new(prepares: HelperPrepare.new) }

      context "methods" do
        it "should parse helper methods" do
          content =<<-EOF
          module PostsHelper
            def used; end
            def unused; end
          end
          EOF
          runner.prepare('app/helpers/posts_helper.rb', content)
          methods = Prepares.helper_methods
          methods.get_methods("PostsHelper").map(&:method_name).should == ["used", "unused"]
        end

        it "should parse helpers" do
          content =<<-EOF
          module PostsHelper
          end
          EOF
          runner.prepare('app/helpers/posts_helper.rb', content)
          content =<<-EOF
          module Admin::UsersHelper
          end
          EOF
          runner.prepare('app/helpers/users_helper.rb', content)
          content =<<-EOF
          module Admin
            module BaseHelper
            end
          end
          EOF
          runner.prepare("app/helpers/base_helper.rb", content)
          helpers = Prepares.helpers
          helpers.map(&:to_s).should == ["PostsHelper", "Admin::UsersHelper", "Admin", "Admin::BaseHelper"]
        end
      end
    end
  end
end
