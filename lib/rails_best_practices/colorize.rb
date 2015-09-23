module RailsBestPractices
  class Colorize
    def self.red(message)
      "\e[31m#{message}\e[0m"
    end

    def self.green(message)
      "\e[32m#{message}\e[0m"
    end
  end
end
