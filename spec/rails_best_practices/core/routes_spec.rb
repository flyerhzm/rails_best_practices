# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Routes do
    let(:routes) { described_class.new }

    it 'adds route' do
      routes.add_route(%w[admin test], 'posts', 'new')
      expect(routes.map(&:to_s)).to eq(['Admin::Test::PostsController#new'])
    end

    context 'route' do
      it 'adds namesapces, controller name and action name' do
        route = Route.new(%w[admin test], 'posts', 'new')
        expect(route.to_s).to eq('Admin::Test::PostsController#new')
      end

      it 'adds controller name with namespace' do
        route = Route.new(['admin'], 'test/posts', 'new')
        expect(route.to_s).to eq('Admin::Test::PostsController#new')
      end

      it 'adds routes without controller' do
        route = Route.new(['posts'], nil, 'new')
        expect(route.to_s).to eq('PostsController#new')
      end
    end
  end
end
