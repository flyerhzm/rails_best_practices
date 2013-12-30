require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe DryBundlerInCapistranoReview do
      let(:runner) { Core::Runner.new(reviews: DryBundlerInCapistranoReview.new) }

      it "should dry bundler in capistrno" do
        content = <<-EOF
        namespace :bundler do
          task :create_symlink, roles: :app do
            shared_dir = File.join(shared_path, 'bundle')
            release_dir = File.join(current_release, '.bundle')
            run("mkdir -p \#{shared_dir} && ln -s \#{shared_dir} \#{release_dir}")
          end

          task :bundle_new_release, roles: :app do
            bundler.create_symlink
            run "cd \#{release_path} && bundle install --without development test"
          end
        end

        after 'deploy:update_code', 'bundler:bundle_new_release'
        EOF
        runner.review('config/deploy.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq("config/deploy.rb:1 - dry bundler in capistrano")
      end

      it "should not dry bundler in capistrano" do
        content = <<-EOF
          require 'bundler/capistrano'
        EOF
        runner.review('config/deploy.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(reviews: DryBundlerInCapistranoReview.new(ignored_files: /deploy\.rb/))
        content = <<-EOF
        namespace :bundler do
          task :create_symlink, roles: :app do
            shared_dir = File.join(shared_path, 'bundle')
            release_dir = File.join(current_release, '.bundle')
            run("mkdir -p \#{shared_dir} && ln -s \#{shared_dir} \#{release_dir}")
          end

          task :bundle_new_release, roles: :app do
            bundler.create_symlink
            run "cd \#{release_path} && bundle install --without development test"
          end
        end

        after 'deploy:update_code', 'bundler:bundle_new_release'
        EOF
        runner.review('config/deploy.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
