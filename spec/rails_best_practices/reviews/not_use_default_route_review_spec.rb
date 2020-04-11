# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NotUseDefaultRouteReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      it 'does not use default route' do
        content = <<-EOF
        RailsBestpracticesCom::Application.routes.draw do |map|
          resources :posts

          match ':controller(/:action(/:id(.:format)))'
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('config/routes.rb:4 - not use default route')
      end

      it 'noes not use default route' do
        content = <<-EOF
        RailsBestpracticesCom::Application.routes.draw do |map|
          resources :posts
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: %r{config/routes\.rb}))
        content = <<-EOF
        RailsBestpracticesCom::Application.routes.draw do |map|
          resources :posts

          match ':controller(/:action(/:id(.:format)))'
        end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
