# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Core
    class Gems < Array
      def has_gem?(gem_name)
        self.find { |gem| gem.name == gem_name }
      end

      def gem_version(gem_name)
        self.find { |gem| gem.name == gem_name }.try(:version)
      end
    end

    # Gem info includes gem name and gem version
    class Gem
      attr_reader :name, :version

      def initialize(name, version)
        @name = name
        @version = version
      end

      def to_s
        "#{@name} (#{@version})"
      end
    end
  end
end
