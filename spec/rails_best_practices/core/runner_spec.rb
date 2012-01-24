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

  describe "determine_config_file" do
    before { @runner = RailsBestPractices::Core::Runner.new }

    context "with a custom config passed in through --config" do
      it 'should return the custom config if the file exists' do
        File.should_receive(:exists?).with("existing.yml").and_return(true)
        @runner.send(:determine_config_file, "existing.yml").should == "existing.yml"
      end
    end

    context "with a custom config in the default location" do
      it "should return the custom config from the default location it exists" do
        config_path = RailsBestPractices::Core::Runner.base_path + '/config/rails_best_practices.yml'
        File.should_receive(:exists?).with(config_path).and_return(true)
        @runner.send(:determine_config_file, nil).should == config_path
      end
    end

    context "when custom config can't be found" do
      it "should return the default config" do
        @runner.send(:determine_config_file, "non-existing.yml").should == RailsBestPractices::Analyzer::DEFAULT_CONFIG
      end
    end
  end
end