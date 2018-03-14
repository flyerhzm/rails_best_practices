# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review config/routes file to make sure not use default route that rails generated.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/22/not-use-default-route-if-you-use-restful-design/
    #
    # Implementation:
    #
    # Review process:
    #   check all method command_call or command node to see if it is the same as rails default route.
    #
    #     map.connect ':controller/:action/:id'
    #     map.connect ':controller/:action/:id.:format'
    #
    #   or
    #
    #     match ':controller(/:action(/:id(.:format)))'
    class NotUseDefaultRouteReview < Review
      interesting_nodes :command_call, :command
      interesting_files ROUTE_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/22/not-use-default-route-if-you-use-restful-design/'

      # check all command nodes
      add_callback :start_command do |node|
        if 'match' == node.message.to_s &&
          ':controller(/:action(/:id(.:format)))' == node.arguments.all.first.to_s
          add_error 'not use default route'
        end
      end
    end
  end
end
