require 'spec_helper'
require 'tmpdir'

module RailsBestPractices
  describe Analyzer do
    subject { Analyzer.new(".") }

    describe '::new' do
      it 'should expand a relative path to an absolute' do
        subject.path.should eq File.expand_path('.')
      end
    end

    describe "expand_dirs_to_files" do
      it "should expand all files in spec directory" do
        dir = File.dirname(__FILE__)
        subject.expand_dirs_to_files(dir).should be_include(dir + '/analyzer_spec.rb')
      end
    end

    describe "file_sort" do
      it "should get models first, mailers, helpers and then others" do
        files = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/helpers/users_helper.rb", "app/models/user.rb", "app/views/users/index.html.haml", "app/views/users/show.html.slim", "lib/user.rb"]
        subject.file_sort(files).should == ["app/models/user.rb", "app/mailers/user_mailer.rb", "app/helpers/users_helper.rb", "app/controllers/users_controller.rb", "app/views/users/index.html.haml", "app/views/users/show.html.slim", "lib/user.rb"]
      end
    end

    describe "file_ignore" do
      before do
        @all = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "app/views/users/show.html.slim", "lib/user.rb"]
        @filtered = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "app/views/users/show.html.slim"]
      end

      it "should ignore lib" do
        subject.file_ignore(@all, 'lib/').should == @filtered
      end

      it "should ignore regexp patterns" do
        subject.file_ignore(@all, /lib/).should == @filtered
      end
    end

    context 'outputs' do
      let(:runner) do
        check1 = Reviews::LawOfDemeterReview.new
        check2 = Reviews::UseQueryAttributeReview.new
        runner = Core::Runner.new(reviews: [check1, check2])
        check1.add_error "law of demeter", "app/models/user.rb", 10
        check2.add_error "use query attribute", "app/models/post.rb", 100
        runner
      end

      before do
        subject.runner = runner
      end

      describe "output_terminal_errors" do
        it "should output errors in terminal" do
          subject.instance_variable_set("@options", {"without-color" => false})

          $origin_stdout = $stdout
          $stdout = StringIO.new
          subject.output_terminal_errors
          result = $stdout.string
          $stdout = $origin_stdout
          result.should == ["app/models/user.rb:10 - law of demeter".red, "app/models/post.rb:100 - use query attribute".red, "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green, "\nFound 2 warnings.".red].join("\n") + "\n"
        end
      end

      describe 'output_html_errors' do
        let(:file){ StringIO.new }

        before do
          File.should_receive(:open).with("output", "w+").once.and_yield(file)
        end

        it 'should support template option' do
          subject.instance_variable_set('@options', {'output-file' => 'output', 'template' => 'some/path.erb'})

          template_file = mock(:template_file)
          template_string = mock(:template_string)

          File.should_receive(:expand_path).with('some/path.erb').once.and_return(template_file)
          File.should_receive(:read).with(template_file).and_return(template_string)
          Erubis::Eruby.should_receive(:new).with(template_string).once.and_return(mock(evaluate: true))

          subject.output_html_errors
        end

        it 'should render output and print errors count' do
          subject.instance_variable_set("@options", {"output-file" => 'output'})

          Erubis::Eruby.should_receive(:new).with(kind_of(String)).once.and_call_original
          subject.output_html_errors
          result = file.string

          errors_count = "<span class='errors_size'>2</span>"
          result.should include errors_count
        end
      end
    end

    describe 'parse_files' do
      it 'should not filter out all files when the path contains "vendor"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'vendor'))
          Dir.mkdir(File.join(random_dir, 'vendor', 'my_project'))
          File.open(File.join(random_dir, 'vendor', 'my_project', 'my_file.rb'), "w") { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'vendor', 'my_project'))
          analyzer.parse_files.should be_include File.join(random_dir, 'vendor', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "spec"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'spec'))
          Dir.mkdir(File.join(random_dir, 'spec', 'my_project'))
          File.open(File.join(random_dir, 'spec', 'my_project', 'my_file.rb'), "w") { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'spec', 'my_project'))
          analyzer.parse_files.should be_include File.join(random_dir, 'spec', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "test"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'test'))
          Dir.mkdir(File.join(random_dir, 'test', 'my_project'))
          File.open(File.join(random_dir, 'test', 'my_project', 'my_file.rb'), "w") { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'test', 'my_project'))
          analyzer.parse_files.should be_include File.join(random_dir, 'test', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "features"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'test'))
          Dir.mkdir(File.join(random_dir, 'test', 'my_project'))
          File.open(File.join(random_dir, 'test', 'my_project', 'my_file.rb'), "w") { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'test', 'my_project'))
          analyzer.parse_files.should be_include File.join(random_dir, 'test', 'my_project', 'my_file.rb')
        }
      end

      it 'should not filter out all files when the path contains "tmp"' do
        Dir.mktmpdir { |random_dir|
          Dir.mkdir(File.join(random_dir, 'tmp'))
          Dir.mkdir(File.join(random_dir, 'tmp', 'my_project'))
          File.open(File.join(random_dir, 'tmp', 'my_project', 'my_file.rb'), "w") { |file| file << 'woot' }
          analyzer = Analyzer.new(File.join(random_dir, 'tmp', 'my_project'))
          analyzer.parse_files.should be_include File.join(random_dir, 'tmp', 'my_project', 'my_file.rb')
        }
      end

    end

  end
end
