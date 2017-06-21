require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Server
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 5.1

    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.autoload_paths << Rails.root.join('app', 'settings')
    config.autoload_paths << Rails.root.join('lib')

    config.encoding = "utf-8"
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.after_initialize do
      if defined?(Rails::Server) || (defined?(Puma))
        # アプリキャッシュにマスター情報を入れておくことでスピードを稼ぐ
        # CacheStore.cache_to_memory!
      end
    end
  end
end
