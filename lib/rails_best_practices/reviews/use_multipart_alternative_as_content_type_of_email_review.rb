# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Make sure to use multipart/alternative as content_type of email.
    #
    # See the best practice details here
    # http://rails-bestpractices.com/posts/41-use-multipart-alternative-as-content_type-of-email.
    #
    # Implementation:
    #
    # Review process:
    #   check class node to remember the class name,
    #   and check the method definition nodes to see if the corresponding mailer views exist or not.
    class UseMultipartAlternativeAsContentTypeOfEmailReview < Review
      interesting_nodes :class, :def
      interesting_files MAILER_FILES
      url "http://rails-bestpractices.com/posts/41-use-multipart-alternative-as-content_type-of-email"

      # check class node to remember the ActionMailer class name.
      add_callback :start_class do |node|
        @klazz_name = node.class_name.to_s
      end

      # check def node and find if the corresponding views exist or not?
      add_callback :start_def do |node|
        name = node.method_name.to_s
        if !rails_canonical_mailer_views?(name)
          add_error("use multipart/alternative as content_type of email")
        end
      end

      private
        # check if rails's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails_canonical_mailer_views?(name)
          if Prepares.gems.gem_version("rails").to_i > 2
            rails3_canonical_mailer_views?(name)
          else
            rails2_canonical_mailer_views?(name)
          end
        end

        # check if rails2's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails2_canonical_mailer_views?(name)
          return true if mailer_files(name).length == 0
          mailer_files(name).any? { |filename| filename.index 'text.html' } &&
            mailer_files(name).any? { |filename| filename.index 'text.plain' }
        end

        # check if rails3's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails3_canonical_mailer_views?(name)
          return true if mailer_files(name).length == 0
          mailer_files(name).any? { |filename| filename.index 'html' } &&
            mailer_files(name).any? { |filename| filename.index 'text' }
        end

        # all mail view files for a method name.
        def mailer_files(name)
          Dir.entries(mailer_directory) { |filename| filename.index name.to_s }
        end

        # the view directory of mailer.
        def mailer_directory
          File.join(Core::Runner.base_path, "app/views/#{@klazz_name.to_s.underscore}")
        end
    end
  end
end
