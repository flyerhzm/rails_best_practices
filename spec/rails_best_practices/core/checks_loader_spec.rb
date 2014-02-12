require 'spec_helper'

module RailsBestPractices::Core
  describe ChecksLoader do
    let(:checks_loader) { ChecksLoader.new(RailsBestPractices::Analyzer::DEFAULT_CONFIG) }

    describe "load_lexicals" do
      it "should load lexical checks from the default configuration" do
        lexicals = checks_loader.load_lexicals
        expect(lexicals.map(&:class)).to include(RailsBestPractices::Lexicals::RemoveTrailingWhitespaceCheck)
      end
    end

    describe "load_reviews" do
      it "should load the reviews from the default the configuration" do
        reviews = checks_loader.load_reviews
        expect(reviews.map(&:class)).to include(RailsBestPractices::Reviews::AlwaysAddDbIndexReview)
      end
    end
  end
end
