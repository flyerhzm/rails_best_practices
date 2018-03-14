# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Module container
    class Modules < Array
      # add module descendant.
      #
      # @param [String] module name
      # @param [String] descendant name
      def add_module_descendant(module_name, descendant)
        mod = find { |mod| mod.to_s == module_name }
        mod.add_descendant(descendant) if mod
      end
    end

    # Module info include module name and module spaces.
    class Mod
      attr_reader :descendants

      def initialize(module_name, modules)
        @module_name = module_name
        @modules = modules
        @descendants = []
      end

      def add_descendant(descendant)
        @descendants << descendant
      end

      def to_s
        if @modules.empty?
          @module_name
        else
          @modules.map { |modu| "#{modu}::" }.join('') + @module_name
        end
      end
    end
  end
end
