# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Runner do
    describe 'load_plugin_reviews' do
      shared_examples_for 'load_plugin_reviews' do
        it 'loads plugins in lib/rails_best_practices/plugins/reviews' do
          runner = described_class.new
          expect(runner.instance_variable_get('@reviews').map(&:class)).to include(
            RailsBestPractices::Plugins::Reviews::NotUseRailsRootReview
          )
        end
      end

      context 'given a path that ends with a slash' do
        before { described_class.base_path = 'spec/fixtures/' }
        it_behaves_like 'load_plugin_reviews'
      end

      context 'given a path that does not end with a slash' do
        before { described_class.base_path = 'spec/fixtures' }
        it_behaves_like 'load_plugin_reviews'
      end
    end
  end
end
