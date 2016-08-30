require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Polyboard
  class Application < Rails::Application
    require Rails.root.join("lib/properties.rb")

    YAML.load_file("#{::Rails.root}/config/gmail_variables.yml")[::Rails.env].each {|k,v| ENV[k] = v }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
