$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rspec'
require 'rails_best_practices'
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.after do
    RailsBestPractices::Prepares.clear
  end
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
