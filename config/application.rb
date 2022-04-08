require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hogemint
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    config.paperclip_defaults = {
        storage: :s3,
        s3_region: ENV["AWS_S3_REGION"],
        s3_permissions: "public-read",
        s3_credentials: {
            s3_host_name: ENV["AWS_S3_HOST_NAME"],
            bucket: ENV["AWS_S3_BUCKET"],
            access_key_id: ENV["AWS_ACCESS_KEY_ID"],
            secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
        }
    }
  end
end
