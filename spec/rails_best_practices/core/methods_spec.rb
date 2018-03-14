# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Methods do
    let(:methods) { Methods.new }

    before :each do
      methods.add_method('Post', 'create')
      methods.add_method('Post', 'destroy')
      methods.add_method('Post', 'save_or_update', {}, 'protected')
      methods.add_method('Post', 'find_by_sql', {}, 'private')
      methods.add_method('Comment', 'create')
    end

    it 'should get_methods' do
      expect(methods.get_methods('Post').map(&:method_name)).to eq(['create', 'destroy', 'save_or_update', 'find_by_sql'])
      expect(methods.get_methods('Post', 'public').map(&:method_name)).to eq(['create', 'destroy'])
      expect(methods.get_methods('Post', 'protected').map(&:method_name)).to eq(['save_or_update'])
      expect(methods.get_methods('Post', 'private').map(&:method_name)).to eq(['find_by_sql'])
      expect(methods.get_methods('Comment').map(&:method_name)).to eq(['create'])
    end

    it 'should has_method?' do
      expect(methods).to be_has_method('Post', 'create', 'public')
      expect(methods).to be_has_method('Post', 'destroy', 'public')
      expect(methods).not_to be_has_method('Post', 'save_or_update', 'public')
      expect(methods).to be_has_method('Post', 'save_or_update', 'protected')
      expect(methods).not_to be_has_method('Post', 'find_by_sql', 'public')
      expect(methods).to be_has_method('Post', 'find_by_sql', 'private')
      expect(methods).not_to be_has_method('Comment', 'destroy')
    end

    it 'should get_method' do
      expect(methods.get_method('Post', 'create', 'public')).not_to be_nil
      expect(methods.get_method('Post', 'create', 'protected')).to be_nil
    end

    it 'should get_all_unused_methods' do
      methods.get_method('Comment', 'create').mark_used
      expect(methods.get_all_unused_methods('public').map(&:method_name)).to eq(['create', 'destroy'])
      expect(methods.get_all_unused_methods('protected').map(&:method_name)).to eq(['save_or_update'])
      expect(methods.get_all_unused_methods('private').map(&:method_name)).to eq(['find_by_sql'])
      expect(methods.get_all_unused_methods.map(&:method_name)).to eq(['create', 'destroy', 'save_or_update', 'find_by_sql'])
    end
  end
end
