# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Make sure to use multipart/alternative as content_type of email.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/41-use-multipart-alternative-as-content_type-of-email.
    #
    # Implementation:
    #
    # Review process:
    #   check class node to remember the class name,
    #   and check the method definition nodes to see if the corresponding mailer views exist or not.
    class UseMultipartAlternativeAsContentTypeOfEmailReview < Review
      def url
        "http://rails-bestpractices.com/posts/41-use-multipart-alternative-as-content_type-of-email"
      end

      def interesting_nodes
        [:class, :defn]
      end

      def interesting_files
        MAILER_FILES
      end

      # check class node to remember the ActionMailer class name.
      def start_class(node)
        @klazz_name = node.class_name
      end

      # check defn node and find if the corresponding views exist or not?
      def start_defn(node)
        name = node.method_name
        if !rails2_mailer_views_exist?(name) && !rails3_mailer_views_exist?(name)
          add_error("use multipart/alternative as content_type of email")
        end
      end

      private
        # check if rails2's syntax mailer views exist or not according to the method name.
        #
        # @param [String] name method name in action_mailer
        def rails2_mailer_views_exist?(name)
          File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.plain.erb") && File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.html.erb") ||
          (File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.plain.haml") && File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.html.haml"))
        end

        # check if rails3's syntax mailer views exist or not according to the method name.
        #
        # @param [String] name method name in action_mailer
        def rails3_mailer_views_exist?(name)
          File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.erb") && File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.html.erb") ||
          (File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.text.haml") && File.exist?("app/views/#{@klazz_name.to_s.underscore}/#{name}.html.haml"))
        end
    end
  end
end
