# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review config/deploy.rb file to make sure using the bundler's capistrano recipe.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/09/02/dry-bundler-in-capistrano/
    #
    # Implementation:
    #
    # Review process:
    #   only check the command nodes to see if there is bundler namespace in config/deploy.rb file,
    #
    #   if the message of command node is "namespace" and the first argument  is "bundler",
    #   then it should use bundler's capistrano recipe.
    class DryBundlerInCapistranoReview < Review
      interesting_nodes :command
      interesting_files DEPLOY_FILES
      url 'https://rails-bestpractices.com/posts/2010/09/02/dry-bundler-in-capistrano/'

      # check call node to see if it is with message "namespace" and argument "bundler".
      add_callback :start_command do |node|
        if node.message.to_s == 'namespace' && node.arguments.all[0].to_s == 'bundler'
          add_error 'dry bundler in capistrano'
        end
      end
    end
  end
end
