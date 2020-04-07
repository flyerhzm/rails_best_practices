# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Error do
    it 'returns error with filename, line number and message' do
      expect(
        described_class.new(
          filename: 'app/models/user.rb', line_number: '100', message: 'not good', type: 'BogusReview'
        ).to_s
      ).to eq('app/models/user.rb:100 - not good')
    end

    it 'returns short filename' do
      Runner.base_path = '../rails-bestpractices.com'
      expect(
        described_class.new(
          filename: '../rails-bestpractices.com/app/models/user.rb',
          line_number: '100',
          message: 'not good',
          type: 'BogusReview'
        ).short_filename
      ).to eq('app/models/user.rb')
    end

    it 'returns first line number' do
      expect(
        described_class.new(
          filename: 'app/models/user.rb', line_number: '50,70,100', message: 'not good', type: 'BogusReview'
        ).first_line_number
      ).to eq('50')
    end
  end
end
