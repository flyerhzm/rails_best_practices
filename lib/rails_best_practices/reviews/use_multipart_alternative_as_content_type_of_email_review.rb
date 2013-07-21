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
        if deliver_method?(name) && rails_canonical_mailer_views?(name)
          add_error("use multipart/alternative as content_type of email")
        end
      end

      private
        # check if rails's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails_canonical_mailer_views?(name)
          rails2_canonical_mailer_views?(name) || rails3_canonical_mailer_views?(name)
        end

        # check if rails2's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails2_canonical_mailer_views?(name)
          (exist?("#{name}.text.html.erb") && !exist?("#{name}.text.plain.erb")) ||
          (exist?("#{name}.text.html.haml") && !exist?("#{name}.text.plain.haml")) ||
          (exist?("#{name}.text.html.slim") && !exist?("#{name}.text.plain.slim")) ||
          (exist?("#{name}.text.html.rhtml") && !exist?("#{name}.text.plain.rhtml"))
        end

        # check if rails3's syntax mailer views are canonical.
        #
        # @param [String] name method name in action_mailer
        def rails3_canonical_mailer_views?(name)
          (exist?("#{name}.html.erb") && !html_tempalte_exists?("#{name}.text")) ||
          (exist?("#{name}.html.haml") && !html_tempalte_exists?("#{name}.text")) ||
          (exist?("#{name}.html.slim") && !html_tempalte_exists?("#{name}.text"))
        end

        # check if the filename existed in the mailer directory.
        def exist?(filename)
          File.exist? File.join(mailer_directory, filename)
        end

        # check if erb, haml or slim exists
        def html_tempalte_exists?(filename)
          exist?("#{filename}.erb") || exist?("#{filename}.haml") || exist?("#{filename}.slim")
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
