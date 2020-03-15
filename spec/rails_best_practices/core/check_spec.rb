# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Check do
    let(:check) { described_class.new }

    context 'debug' do
      it 'is debug mode' do
        described_class.debug
        expect(described_class).to be_debug
        described_class.class_eval { @debug = false }
      end
    end
  end
end
