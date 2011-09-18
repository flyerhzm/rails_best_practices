# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review config/deploy.rb file to make sure using the bundler's capistrano recipe.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/51-dry-bundler-in-capistrano
    #
    # Implementation:
    #
    # Review process:
    #   only check the command nodes to see if there is bundler namespace in config/deploy.rb file,
    #
    #   if the message of command node is "namespace" and the first argument  is "bundler",
    #   then it should use bundler's capistrano recipe.
    class DryBundlerInCapistranoReview < Review
      def url
        "http://rails-bestpractices.com/posts/51-dry-bundler-in-capistrano"
      end

      def interesting_nodes
        [:command]
      end

      def interesting_files
        /config\/deploy.rb/
      end

      # check call node to see if it is with message "namespace" and argument "bundler".
      def start_command(node)
        if "namespace" == node.message.to_s && "bundler" == node.arguments.all[0].to_s
          add_error "dry bundler in capistrano"
        end
      end
    end
  end
end
