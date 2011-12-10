# encoding: utf-8
module RailsBestPractices
  module Core
    # Module container
    class Modules < Array
      # add module decendant.
      #
      # @param [String] module name
      # @param [String] decendant name
      def add_module_decendant(module_name, decendant)
        mod = find { |mod| mod.to_s == module_name }
        mod.add_decendant(decendant) if mod
      end
    end

    # Module info include module name and module spaces.
    class Mod
      attr_reader :decendants

      def initialize(module_name, modules)
        @module_name = module_name
        @modules = modules
        @decendants = []
      end

      def add_decendant(decendant)
        @decendants << decendant
      end

      def to_s
        if @modules.empty?
          @module_name
        else
          @modules.map { |modu| "#{modu}::" }.join("") + @module_name
        end
      end
    end
  end
end
