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
        @mod.should_receive(:add_decendant).with("PostsController")
        subject.add_module_decendant("PostsHelper", "PostsController")
      end
    end

    context "Mod" do
      subject {
        Mod.new("UsersHelper", ["Admin"]).tap do |mod|
          mod.add_decendant("Admin::UsersController")
        end
      }
      its(:to_s) { should == "Admin::UsersHelper" }
      its(:decendants) { should == ["Admin::UsersController"] }
    end
  end
end
