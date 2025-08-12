ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "factory_bot_rails"

RSpec.configure do |config|
  # Use transactional fixtures for database cleanup in model/request specs
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot conveniences
  config.include FactoryBot::Syntax::Methods
end
