# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review model files to make sure to use attr_accessible, attr_protected or strong_parameters to protect mass assignment.
    #
    # See the best practices details here https://rails-bestpractices.com/posts/2012/03/06/protect-mass-assignment/
    #
    # Implmentation:
    #
    # Review process:
    #   check nodes to see if there is a command with message attr_accessible or attr_protected,
    #   or include ActiveModel::ForbiddenAttributesProtection.
    class ProtectMassAssignmentReview < Review
      interesting_files MODEL_FILES
      interesting_nodes :class, :command, :var_ref, :vcall, :fcall
      url 'https://rails-bestpractices.com/posts/2012/03/06/protect-mass-assignment/'

      # we treat it as mass assignment by default.
      add_callback :start_class do |node|
        @mass_assignement = true
        check_activerecord_version
        check_whitelist_attributes_config
        check_include_forbidden_attributes_protection_config
      end

      # check if it is ActiveRecord::Base subclass and
      # if it sets config.active_record.whitelist_attributes to true.
      add_callback :end_class do |node|
        check_active_record(node)

        add_error 'protect mass assignment' if @mass_assignement
      end

      # check if it is attr_accessible or attr_protected command,
      # if it uses strong_parameters,
      # and if it uses devise.
      add_callback :start_command do |node|
        check_rails_builtin(node)
        check_strong_parameters(node)
        check_devise(node)
      end

      # check if it is attr_accessible, attr_protected, acts_as_authlogic without parameters.
      add_callback :start_var_ref, :start_vcall do |node|
        check_rails_builtin(node)
        check_authlogic(node)
      end

      # check if it uses authlogic.
      add_callback :start_fcall do |node|
        check_authlogic(node)
      end

      private

        def check_activerecord_version
          if Prepares.gems.gem_version('activerecord').to_i > 3
            @mass_assignement = false
          end
        end

        def check_whitelist_attributes_config
          if 'true' == Prepares.configs['config.active_record.whitelist_attributes']
            @whitelist_attributes = true
          end
        end

        def check_include_forbidden_attributes_protection_config
          if 'true' == Prepares.configs['railsbp.include_forbidden_attributes_protection']
            @mass_assignement = false
          end
        end

        def check_rails_builtin(node)
          if @whitelist_attributes || [node.to_s, node.message.to_s].any? { |str| %w(attr_accessible attr_protected).include? str }
            @mass_assignement = false
          end
        end

        def check_strong_parameters(command_node)
          if 'include' == command_node.message.to_s && 'ActiveModel::ForbiddenAttributesProtection' == command_node.arguments.all.first.to_s
            @mass_assignement = false
          end
        end

        def check_devise(command_node)
          if 'devise' == command_node.message.to_s
            @mass_assignement = false
          end
        end

        def check_authlogic(node)
          if [node.to_s, node.message.to_s].include? 'acts_as_authentic'
            @mass_assignement = false
          end
        end

        def check_active_record(const_path_ref_node)
          if 'ActiveRecord::Base' != const_path_ref_node.base_class.to_s
            @mass_assignement = false
          end
        end
    end
  end
end
