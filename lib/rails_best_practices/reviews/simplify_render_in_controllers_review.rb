# encoding: utf-8
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
      interesting_nodes :command
      interesting_files CONTROLLER_FILES
      url "http://rails-bestpractices.com/posts/62-simplify-render-in-controllers"

      # check command node in the controller file,
      # if its message is render and the arguments contain a key action, template or file,
      # then it should be replaced by simplified syntax.
      add_callback :start_command do |node|
        if "render" == node.message.to_s
          keys = node.arguments.all.first.hash_keys
          if keys && keys.size == 1 &&
             (keys.include?("action") || keys.include?("template") || keys.include?("file"))
            add_error 'simplify render in controllers'
          end
        end
      end
    end
  end
end
