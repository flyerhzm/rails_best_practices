require 'spec_helper'

describe RailsBestPractices::Checks::DryBundlerInCapistranoCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::DryBundlerInCapistranoCheck.new)
  end

  it "should dry bundler in capistrno" do
    content = <<-EOF
    namespace :bundler do
      task :create_symlink, :roles => :app do
        shared_dir = File.join(shared_path, 'bundle')
        release_dir = File.join(current_release, '.bundle')
        run("mkdir -p \#{shared_dir} && ln -s \#{shared_dir} \#{release_dir}")
      end

      task :bundle_new_release, :roles => :app do
        bundler.create_symlink
        run "cd \#{release_path} && bundle install --without development test"
      end
    end

    after 'deploy:update_code', 'bundler:bundle_new_release'
    EOF
    @runner.check('config/deploy.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/deploy.rb:1 - dry bundler in capistrano"
  end

  it "should not dry bundler in capistrano" do
    content = <<-EOF
      require 'bundler/capistrano'
    EOF
    @runner.check('config/deploy.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
