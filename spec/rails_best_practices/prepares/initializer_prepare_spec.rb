require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe InitializerPrepare do
      let(:runner) { Core::Runner.new(prepares: InitializerPrepare.new) }

      context 'initializers' do
        it 'should set include_forbidden_attributes_protection config' do
          content = <<-EOF
          class AR
            ActiveRecord::Base.send(:include, ActiveModel::ForbiddenAttributesProtection)
          end
          EOF
          runner.prepare('config/initializers/ar.rb', content)
          configs = Prepares.configs
          expect(configs['railsbp.include_forbidden_attributes_protection']).to eq('true')
        end

        it 'should not set include_forbidden_attributes_protection config' do
          content = <<-EOF
          class AR
          end
          EOF
          runner.prepare('config/initializers/ar.rb', content)
          configs = Prepares.configs
          expect(configs['railsbp.include_forbidden_attributes_protection']).to be_nil
        end
      end
    end
  end
end
