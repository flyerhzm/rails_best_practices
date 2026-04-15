# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe Runner do
    describe '#parse_html_template (haml)' do
      # Load before `it ... if:` metadata is evaluated (nested under Core, so use top-level constants).
      require 'haml'

      let(:runner) { described_class.new }
      let(:haml_path) { 'app/views/posts/show.html.haml' }
      let(:haml_source) { "%p.title Hello\n= link_to 'x', posts_path" }

      context 'when Haml::VERSION is forced in the app environment' do
        let(:template) { "%p\n" }

        it 'uses Engine.new(template).precompiled and routes through parse_html_template' do
          stub_const('Haml::VERSION', '5.2.0')
          engine = instance_double(::Haml::Engine, precompiled: +"compiled\n")
          expect(::Haml::Engine).to receive(:new).with(template).and_return(engine)
          expect(runner.send(:parse_html_template, 'app/x.haml', template)).to eq("compiled\n")
        end

        it 'uses Engine.new with no template arg, then #call(template) — old Haml-5-only code would fail here' do
          stub_const('Haml::VERSION', '6.0.0')
          engine = double('haml6_engine')
          expect(::Haml::Engine).to receive(:new).with(no_args).and_return(engine)
          expect(engine).to receive(:call).with(template).and_return(+"from_call\n")
          # If implementation wrongly does `Engine.new(template).precompiled`, `new` is invoked with
          # `[template]` and this example fails immediately.
          expect(runner.send(:parse_html_template, 'app/x.haml', template)).to eq("from_call\n")
        end
      end
    end

    describe 'load_plugin_reviews' do
      shared_examples_for 'load_plugin_reviews' do
        it 'loads plugins in lib/rails_best_practices/plugins/reviews' do
          runner = described_class.new
          expect(runner.instance_variable_get('@reviews').map(&:class)).to include(
            RailsBestPractices::Plugins::Reviews::NotUseRailsRootReview
          )
        end
      end

      context 'given a path that ends with a slash' do
        before { described_class.base_path = 'spec/fixtures/' }
        it_behaves_like 'load_plugin_reviews'
      end

      context 'given a path that does not end with a slash' do
        before { described_class.base_path = 'spec/fixtures' }
        it_behaves_like 'load_plugin_reviews'
      end
    end
  end
end
