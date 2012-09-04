require 'spec_helper'

module RailsBestPractices::Core
  describe Check do
    let(:check) { Check.new }

    context "callback" do
      it "should add callback to start_call" do
        execute = false
        check.class.add_callback "start_call" do
          execute = true
        end
        node = stub(sexp_type: :call)
        check.node_start(node)
        execute.should be_true
      end

      it "should ad callbacks to end_call" do
        execute = false
        check.class.add_callback "end_call" do
          execute = true
        end
        node = stub(sexp_type: :call)
        check.node_end(node)
        execute.should be_true
      end
    end

    context "debug" do
      it "should be debug mode" do
        Check.debug
        Check.should be_debug
        Check.class_eval { @debug = false }
      end
    end
  end
end
