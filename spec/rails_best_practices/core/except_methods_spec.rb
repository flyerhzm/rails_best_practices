# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Check::Exceptable do
    let(:method) { Method.new 'BlogPost', 'approve', 'public', {} }

    context 'wildcard class and method' do
      let(:except_method) { '*#*' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql true
      end
    end

    context 'wildcard class and matching explicit method' do
      let(:except_method) { '*#approve' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql true
      end
    end

    context 'wildcard class and non-matching explicit method' do
      let(:except_method) { '*#disapprove' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql false
      end
    end

    context 'matching class and wildcard method' do
      let(:except_method) { 'BlogPost#*' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql true
      end
    end

    context 'non-matching class and wildcard method' do
      let(:except_method) { 'User#*' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql false
      end
    end

    context 'matching class and matching method' do
      let(:except_method) { 'BlogPost#approve' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql true
      end
    end

    context 'non-matching class and non-matching method' do
      let(:except_method) { 'User#disapprove' }

      it 'matches' do
        expect(Check::Exceptable.matches(method, except_method)).to eql false
      end
    end
  end
end
