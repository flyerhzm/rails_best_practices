require 'spec_helper'

describe RailsBestPractices::Core::Runner do
  describe "load_plugin_reviews" do
    shared_examples_for 'load_plugin_reviews' do
      it "should load plugins in lib/rails_best_practices/plugins/reviews" do
        runner = RailsBestPractices::Core::Runner.new
        runner.instance_variable_get('@reviews').map(&:class).should include(RailsBestPractices::Plugins::Reviews::NotUseRailsRootReview)
      end
    end

    context "given a path that ends with a slash" do
      before { RailsBestPractices::Core::Runner.base_path = 'spec/fixtures/' }
      it_should_behave_like 'load_plugin_reviews'
    end

    context "given a path that does not end with a slash" do
      before { RailsBestPractices::Core::Runner.base_path = 'spec/fixtures' }
      it_should_behave_like 'load_plugin_reviews'
    end
  end
end