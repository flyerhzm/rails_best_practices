# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Prepare Gemfile and review Capfile file to make sure using turbo-sprocket-rails3
    #
    # See the best practice details here http://rails-bestpractices.com/posts/704-speed-up-assets-precompile-with-turbo-sprockets-rails3
    #
    # Implementation:
    #
    # Review process:
    #   only check if turbo-sprockets-rails3 gem is not used and load 'deploy/assets' in Capfile.
    class UseTurboSprocketsRails3Review < Review
      interesting_nodes :command
      interesting_files CAPFILE
      url "http://rails-bestpractices.com/posts/704-speed-up-assets-precompile-with-turbo-sprockets-rails3"

      # check command node to see if load 'deploy/assets'
      add_callback :start_command do |node|
        if Prepares.gems.gem_version("rails").to_i == 3
          if !Prepares.gems.has_gem?("turbo-sprockets-rails3") && "load" == node.message.to_s && "deploy/assets" == node.arguments.to_s
            add_error "speed up assets precompile with turbo-sprockets-rails3"
          end
        end
      end
    end
  end
end
