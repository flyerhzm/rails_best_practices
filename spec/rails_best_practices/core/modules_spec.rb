# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Modules do
    it { is_expected.to be_a_kind_of Array }

    context 'Modules' do
      before { @mod = Mod.new('PostsHelper', []) }
      subject { described_class.new.tap { |modules| modules << @mod } }
      it 'adds descendant to the corresponding module' do
        expect(@mod).to receive(:add_descendant).with('PostsController')
        subject.add_module_descendant('PostsHelper', 'PostsController')
      end
    end

    context 'Mod' do
      subject { Mod.new('UsersHelper', ['Admin']).tap { |mod| mod.add_descendant('Admin::UsersController') } }
      it { expect(subject.to_s).to eq('Admin::UsersHelper') }
      it { expect(subject.descendants).to eq(['Admin::UsersController']) }
    end
  end
end
