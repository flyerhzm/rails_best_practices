require 'spec_helper'

describe RailsBestPractices do

  describe "expand_dirs_to_files" do
    require 'find'
    it "should expand all files in spec directory" do
      dir = File.dirname(__FILE__)
      RailsBestPractices.expand_dirs_to_files(dir).should be_include(dir + '/rails_best_practices_spec.rb')
    end
  end

  describe "file_sort" do
    it "should get models first, then mailers" do
      files = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "lib/user.rb"]
      RailsBestPractices.file_sort(files).should == ["app/models/user.rb", "app/mailers/user_mailer.rb", "app/controllers/users_controller.rb", "app/views/users/index.html.haml", "lib/user.rb"]
    end
  end

  describe "file_ignore" do
    it "should ignore lib" do
      files = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "lib/user.rb"]
      RailsBestPractices.file_ignore(files, 'lib/').should == ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml"]
    end
  end

  describe "output_terminal_errors" do
    let(:check1) { RailsBestPractices::Reviews::LawOfDemeterReview.new }
    let(:check2) { RailsBestPractices::Reviews::UseQueryAttributeReview.new }
    let(:runner) { RailsBestPractices::Core::Runner.new(:reviews => [check1, check2]) }

    before do
      check1.add_error "law of demeter", "app/models/user.rb", 10
      check2.add_error "use query attribute", "app/models/post.rb", 100
      RailsBestPractices.runner = runner
      $origin_stdout = $stdout
      $stdout = StringIO.new
    end

    after do
      $stdout = $origin_stdout
    end

    context 'default options' do
      it "returns a list of color formatted errors" do
        RailsBestPractices.instance_variable_set("@options", {"without-color" => false})
        RailsBestPractices.output_terminal_errors
        result = $stdout.string
        result.should == ["app/models/user.rb:10 - law of demeter".red, "app/models/post.rb:100 - use query attribute".red, "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green, "\nFound 2 warnings.".red].join("\n") + "\n"
      end
    end

    context 'given --with-urls option' do
      it "returns a list of errors showing urls to the website" do
        RailsBestPractices.instance_variable_set("@options", {"with-urls" => true})
        RailsBestPractices.output_terminal_errors
        result = $stdout.string
        result.should == ["app/models/user.rb:10 - law of demeter (http://rails-bestpractices.com/posts/15-the-law-of-demeter)".red, "app/models/post.rb:100 - use query attribute (http://rails-bestpractices.com/posts/56-use-query-attribute)".red, "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green, "\nFound 2 warnings.".red].join("\n") + "\n"
      end
    end
  end
end
