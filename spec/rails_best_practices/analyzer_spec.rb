# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

module RailsBestPractices
  describe Analyzer do
    subject { Analyzer.new('.') }

    describe '::new' do
      it 'should expand a relative path to an absolute' do
        expect(subject.path).to eq File.expand_path('.')
      end
    end

    describe 'expand_dirs_to_files' do
      it 'should expand all files in spec directory' do
        dir = File.dirname(__FILE__)
        expect(subject.expand_dirs_to_files(dir)).to be_include(dir + '/analyzer_spec.rb')
      end
    end

    describe 'file_sort' do
      it 'should get models first, mailers, helpers and then others' do
        files = ['app/controllers/users_controller.rb', 'app/mailers/user_mailer.rb', 'app/helpers/users_helper.rb', 'app/models/user.rb', 'app/views/users/index.html.haml', 'app/views/users/show.html.slim', 'lib/user.rb']
        expect(subject.file_sort(files)).to eq(['app/models/user.rb', 'app/mailers/user_mailer.rb', 'app/helpers/users_helper.rb', 'app/controllers/users_controller.rb', 'app/views/users/index.html.haml', 'app/views/users/show.html.slim', 'lib/user.rb'])
      end
    end

    describe 'file_ignore' do
      before do
        @all = ['app/controllers/users_controller.rb', 'app/mailers/user_mailer.rb', 'app/models/user.rb', 'app/views/users/index.html.haml', 'app/views/users/show.html.slim', 'lib/user.rb']
        @filtered = ['app/controllers/users_controller.rb', 'app/mailers/user_mailer.rb', 'app/models/user.rb', 'app/views/users/index.html.haml', 'app/views/users/show.html.slim']
      end

      it 'should ignore lib' do
        expect(subject.file_ignore(@all, 'lib/')).to eq(@filtered)
      end

      it 'should ignore regexp patterns' do
        expect(subject.file_ignore(@all, /lib/)).to eq(@filtered)
      end
    end

    describe 'output' do
      subject { described_class.new('.', 'format' => format) }

      before do
        subject.stub(:output_terminal_errors)
        subject.stub(:output_html_errors)
        subject.stub(:output_yaml_errors)
        subject.stub(:output_xml_errors)

        subject.output
      end

      context 'when format is not set' do
        let(:format) { nil }

        it 'runs text output' do
          expect(subject).to have_received(:output_terminal_errors)
        end
      end

      context 'when format is yaml' do
        let(:format) { 'yaml' }

        it 'runs yaml output' do
          expect(subject).to have_received(:output_yaml_errors)
        end
      end

      context 'when format is html' do
        let(:format) { 'html' }

        it 'runs html output' do
          expect(subject).to have_received(:output_html_errors)
        end
      end

      context 'when format is xml' do
        let(:format) { 'xml' }

        it 'runs xml output' do
          expect(subject).to have_received(:output_xml_errors)
        end
      end
    end

    describe 'output_terminal_errors' do
      it 'should output errors in terminal' do
        check1 = Reviews::LawOfDemeterReview.new
        check2 = Reviews::UseQueryAttributeReview.new
        runner = Core::Runner.new(reviews: [check1, check2])
        check1.add_error 'law of demeter', 'app/models/user.rb', 10
        check2.add_error 'use query attribute', 'app/models/post.rb', 100
        subject.runner = runner
        subject.instance_variable_set('@options', 'without-color' => false)

        $origin_stdout = $stdout
        $stdout = StringIO.new
        subject.output_terminal_errors
        result = $stdout.string
        $stdout = $origin_stdout
        expect(result).to eq([
          "\e[31mapp/models/user.rb:10 - law of demeter\e[0m",
          "\e[31mapp/models/post.rb:100 - use query attribute\e[0m",
          "\e[32m\nPlease go to https://rails-bestpractices.com to see more useful Rails Best Practices.\e[0m",
          "\e[31m\nFound 2 warnings.\e[0m"].join("\n") + "\n")
      end
    end

    describe 'output_json_errors' do
      let(:output_file) { 'rails_best_practices_output.json' }

      subject do
        described_class.new('.',
          'format' => 'json',
          'output-file' => output_file
        )
      end

      let(:check1) { Reviews::LawOfDemeterReview.new }
      let(:check2) { Reviews::UseQueryAttributeReview.new }
      let(:runner) { Core::Runner.new(reviews: [check1, check2]) }
      let(:result) { File.read(output_file) }

      before do
        check1.add_error('law of demeter', 'app/models/user.rb', 10)
        check2.add_error('use query attribute', 'app/models/post.rb', 100)
        subject.runner = runner
        subject.output
      end

      after do
        File.delete(output_file) if File.exist?(output_file)
      end

      it 'saves output as json into output file' do
        expect(result).to eq '[{"filename":"app/models/user.rb","line_number":"10","message":"law of demeter"},{"filename":"app/models/post.rb","line_number":"100","message":"use query attribute"}]'
      end
    end

    describe 'parse_files' do
      it 'should not filter out all files when the path contains "vendor"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'vendor'))
          Dir.mkdir(File.join(random_dir, 'vendor', 'my_project'))
          File.open(File.join(random_dir, 'vendor', 'my_project', 'my_file.rb'), 'w') { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'vendor', 'my_project'))
          expect(analyzer.parse_files).to be_include File.join(random_dir, 'vendor', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "spec"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'spec'))
          Dir.mkdir(File.join(random_dir, 'spec', 'my_project'))
          File.open(File.join(random_dir, 'spec', 'my_project', 'my_file.rb'), 'w') { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'spec', 'my_project'))
          expect(analyzer.parse_files).to be_include File.join(random_dir, 'spec', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "test"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'test'))
          Dir.mkdir(File.join(random_dir, 'test', 'my_project'))
          File.open(File.join(random_dir, 'test', 'my_project', 'my_file.rb'), 'w') { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'test', 'my_project'))
          expect(analyzer.parse_files).to be_include File.join(random_dir, 'test', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "features"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'test'))
          Dir.mkdir(File.join(random_dir, 'test', 'my_project'))
          File.open(File.join(random_dir, 'test', 'my_project', 'my_file.rb'), 'w') { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'test', 'my_project'))
          expect(analyzer.parse_files).to be_include File.join(random_dir, 'test', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "tmp"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'tmp'))
          Dir.mkdir(File.join(random_dir, 'tmp', 'my_project'))
          File.open(File.join(random_dir, 'tmp', 'my_project', 'my_file.rb'), 'w') { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'tmp', 'my_project'))
          expect(analyzer.parse_files).to be_include File.join(random_dir, 'tmp', 'my_project', 'my_file.rb')
        }
      end
    end
  end
end
