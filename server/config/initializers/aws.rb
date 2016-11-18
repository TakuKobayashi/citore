# Be sure to restart your server when you modify this file.

# Configure AWS SDK for Ruby.
Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)