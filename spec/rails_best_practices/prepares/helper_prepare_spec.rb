require 'spec_helper'

describe RailsBestPractices::Prepares::HelperPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:parepare => RailsBestPractices::Prepares::HelperPrepare.new) }

  context "methods" do
    it "should parse helper methods" do
      content =<<-EOF
      module PostsHelper
        def used; end
        def unused; end
      end
      EOF
      runner.prepare('app/helpers/posts_helper.rb', content)
      methods = RailsBestPractices::Prepares.helper_methods
      methods.get_methods("PostsHelper").map(&:method_name).should == ["used", "unused"]
    end
  end
end
