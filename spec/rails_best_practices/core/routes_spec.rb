# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Routes do
    let(:routes) { Routes.new }

    it 'should add route' do
      routes.add_route(['admin', 'test'], 'posts', 'new')
      expect(routes.map(&:to_s)).to eq(['Admin::Test::PostsController#new'])
    end

    context 'route' do
      it 'should add namesapces, controller name and action name' do
        route = Route.new(['admin', 'test'], 'posts', 'new')
        expect(route.to_s).to eq('Admin::Test::PostsController#new')
      end

      it 'should add controller name with namespace' do
        route = Route.new(['admin'], 'test/posts', 'new')
        expect(route.to_s).to eq('Admin::Test::PostsController#new')
      end

      it 'should add routes without controller' do
        route = Route.new(['posts'], nil, 'new')
        expect(route.to_s).to eq('PostsController#new')
      end
    end
  end
end
