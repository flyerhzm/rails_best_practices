# frozen_string_literal: true

module RailsBestPractices
  module Core
    class ChecksLoader
      def initialize(config)
        @config = config
      end

      # load all lexical checks.
      def load_lexicals
        load_checks_from_config { |check_name| RailsBestPractices::Lexicals.const_get(check_name) }
      end

      # load all reviews according to configuration.
      def load_reviews
        load_checks_from_config do |check_name|
          RailsBestPractices::Reviews.const_get(check_name.gsub(/Check$/, 'Review'))
        end
      end

      private

      # read the checks from yaml config.
      def checks_from_config
        @checks ||= YAML.load_file @config
      end

      # load all checks from the configuration
      def load_checks_from_config(&block)
        checks_from_config.each_with_object([]) do |check, active_checks|
          check_instance = instantiate_check(block, *check)
          active_checks << check_instance unless check_instance.nil?
        end
      end

      # instantiates a check
      def instantiate_check(block, check_name, options)
        check_class = load_check_class(check_name, &block)
        check_class&.new(options || {})
      end

      # loads the class for a check by calling the given block
      def load_check_class(check_name)
        yield(check_name)
      rescue NameError
        # nothing to do, the check does not exist
      end
    end
  end
end
