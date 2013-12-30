require 'spec_helper'

module RailsBestPractices::Core
  describe Modules do
    it { should be_a_kind_of Array }

    context "Modules" do
      before do
        @mod = Mod.new("PostsHelper", [])
      end
      subject { Modules.new.tap { |modules| modules << @mod } }
      it "should add decendant to the corresponding module" do
        expect(@mod).to receive(:add_decendant).with("PostsController")
        subject.add_module_decendant("PostsHelper", "PostsController")
      end
    end

    context "Mod" do
      subject {
        Mod.new("UsersHelper", ["Admin"]).tap do |mod|
          mod.add_decendant("Admin::UsersController")
        end
      }
      it { expect(subject.to_s).to eq("Admin::UsersHelper") }
      it { expect(subject.decendants).to eq(["Admin::UsersController"]) }
    end
  end
end
