# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure using simplified syntax for render.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/62-simplify-render-in-controllers.
    #
    # Implementation:
    #
    # Review process:
    #   check all render method commands in controller files,
    #   if there is a key 'action', 'template' or 'file' in the argument,
    #   then they should be replaced by simplified syntax.
    class SimplifyRenderInControllersReview < Review
      def url
        "http://rails-bestpractices.com/posts/62-simplify-render-in-controllers"
      end

      def interesting_nodes
        [:command]
      end

      def interesting_files
        CONTROLLER_FILES
      end

      # check command node in the controller file,
      # if its message is render and the arguments contain a key action, template or file,
      # then it should be replaced by simplified syntax.
      def start_command(node)
        if "render" == node.message.to_s
          keys = node.arguments.all[0].hash_keys
          if keys && keys.size == 1 &&
             (keys.include?("action") || keys.include?("template") || keys.include?("file"))
            add_error 'simplify render in controllers'
          end
        end
      end
    end
  end
end
