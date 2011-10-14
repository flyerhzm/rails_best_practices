require 'spec_helper'

describe RailsBestPractices::Core::Runner do

  before { RailsBestPractices::Core::Runner.base_path = 'spec/fixtures/' }

  describe "load_plugin_reviews" do
    it "should load plugins in lib/rails_best_practices/plugins/reviews" do
      runner = RailsBestPractices::Core::Runner.new
      runner.instance_variable_get('@reviews').map(&:class).should include(RailsBestPractices::Plugins::Reviews::NotUseRailsRootReview)
    end
  end
end