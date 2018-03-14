# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe ConfigPrepare do
      let(:runner) { Core::Runner.new(prepares: ConfigPrepare.new) }

      context 'configs' do
        it 'should parse configs' do
          content = <<-EOF
          module RailsBestPracticesCom
            class Application < Rails::Application
              config.active_record.whitelist_attributes = true
            end
          end
          EOF
          runner.prepare('config/application.rb', content)
          configs = Prepares.configs
          expect(configs['config.active_record.whitelist_attributes']).to eq('true')
        end
      end
    end
  end
end
