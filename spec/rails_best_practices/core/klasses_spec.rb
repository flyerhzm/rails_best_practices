# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Klasses do
    it { is_expected.to be_a_kind_of Array }

    context 'Klass' do
      describe '#class_name' do
        it 'gets class name without module' do
          klass = Klass.new('BlogPost', 'Post', [])
          expect(klass.class_name).to eq('BlogPost')
        end

        it 'gets class name with moduel' do
          klass = Klass.new('BlogPost', 'Post', ['Admin'])
          expect(klass.class_name).to eq('Admin::BlogPost')
        end
      end

      describe '#extend_class_name' do
        it 'gets extend class name without module' do
          klass = Klass.new('BlogPost', 'Post', [])
          expect(klass.extend_class_name).to eq('Post')
        end

        it 'gets extend class name with module' do
          klass = Klass.new('BlogPost', 'Post', ['Admin'])
          expect(klass.extend_class_name).to eq('Admin::Post')
        end
      end

      it 'gets to_s equal to class_name' do
        klass = Klass.new('BlogPost', 'Post', ['Admin'])
        expect(klass.to_s).to eq(klass.class_name)
      end
    end
  end
end
