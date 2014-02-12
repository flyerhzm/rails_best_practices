require 'spec_helper'

module RailsBestPractices::Core
  describe Runner do
    describe "load_plugin_reviews" do
      shared_examples_for 'load_plugin_reviews' do
        it "should load plugins in lib/rails_best_practices/plugins/reviews" do
          runner = Runner.new
          expect(runner.instance_variable_get('@reviews').map(&:class)).to include(RailsBestPractices::Plugins::Reviews::NotUseRailsRootReview)
        end
      end

      context "given a path that ends with a slash" do
        before { Runner.base_path = 'spec/fixtures/' }
        it_should_behave_like 'load_plugin_reviews'
      end

      context "given a path that does not end with a slash" do
        before { Runner.base_path = 'spec/fixtures' }
        it_should_behave_like 'load_plugin_reviews'
      end
    end
  end
end
