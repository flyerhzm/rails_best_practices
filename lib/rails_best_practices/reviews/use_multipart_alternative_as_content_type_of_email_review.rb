# encoding: utf-8
require 'rails_best_practices/core/runner'
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
        return unless deliver_method?(name)
        if rails2_canonical_mailer_views?(name) || rails3_canonical_mailer_views?(name)
          add_error("use multipart/alternative as content_type of email")
        end
      end

      private
        # check if rails2's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails2_canonical_mailer_views?(name)
          (exist?("#{name}.text.html.erb") && !exist?("#{name}.text.plain.erb")) ||
          (exist?("#{name}.text.html.haml") && !exist?("#{name}.text.plain.haml")) ||
          (exist?("#{name}.text.html.rhtml") && !exist?("#{name}.text.plain.rhtml"))
        end

        # check if rails3's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails3_canonical_mailer_views?(name)
          (exist?("#{name}.html.erb") && !haml_or_erb_exists?("#{name}.text")) ||
          (exist?("#{name}.html.haml") && !haml_or_erb_exists?("#{name}.text") )
        end

        # check if the filename existed in the mailer directory.
        def exist?(filename)
          File.exist? File.join(mailer_directory, filename)
        end

        # check if haml or erb exists
        def haml_or_erb_exists?(filename)
          exist?("#{filename}.erb") || exist?("#{filename}.haml")
        end

        # check if the method is a deliver_method.
        #
        # @param [String] name the name of the method
        def deliver_method?(name)
          Dir.entries(mailer_directory).find { |filename| filename.index name.to_s }
        rescue
          false
        end

        # the view directory of mailer.
        def mailer_directory
          File.join(Core::Runner.base_path, "app/views/#{@klazz_name.to_s.underscore}")
        end
    end
  end
end
