Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resource :tweet_voice, controller: :tweet_voice, only: [] do
    get 'search'
    get 'download'
  end

  resource :apk_downloader, controller: :apk_downloader, only: [] do
    get 'warakatsu'
  end

  mount Messenger::Bot::Space => "/sugarcoat/bot/"

  namespace :sugarcoat do
    resource :bot, controller: :bot, only: [] do
      get 'speak'
      get 'callback'
      post 'callback'
    end

    resource :landing, controller: :landing, only: [] do
      get 'page'
    end
  end

  namespace :citore do
    resource :voice, controller: :voice, only: [] do
      get 'search'
      get 'download'
    end
  end
end
