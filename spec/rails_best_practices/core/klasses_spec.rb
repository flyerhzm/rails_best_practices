require 'spec_helper'

module RailsBestPractices::Core
  describe Klasses do
    it { should be_a_kind_of Array }

    context "Klass" do
      context "#class_name" do
        it "gets class name without module" do
          klass = Klass.new("BlogPost", "Post", [])
          klass.class_name.should == "BlogPost"
        end

        it "gets class name with moduel" do
          klass = Klass.new("BlogPost", "Post", ["Admin"])
          klass.class_name.should == "Admin::BlogPost"
        end
      end

      context "#extend_class_name" do
        it "gets extend class name without module" do
          klass = Klass.new("BlogPost", "Post", [])
          klass.extend_class_name.should == "Post"
        end

        it "gets extend class name with module" do
          klass = Klass.new("BlogPost", "Post", ["Admin"])
          klass.extend_class_name.should == "Admin::Post"
        end
      end

      it "gets to_s equal to class_name" do
        klass = Klass.new("BlogPost", "Post", ["Admin"])
        klass.to_s.should == klass.class_name
      end
    end
  end
end
