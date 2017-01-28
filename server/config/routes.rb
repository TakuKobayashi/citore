Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/auth/:provider/callback" => "sns#oauth_callback"

  resource :sns, controller: :sns, only: [] do
    get :admin_index
  end

  resource :apk_downloader, controller: :apk_downloader, only: [] do
    get 'warakatsu'
    get 'citore'
  end

  resource :variable_template, controller: :variable_template, only: [] do
    get 'warakatsu_apk_download'
    get 'citore_apk_download'
    get 'citore_movie'
    get 'citore_slide'
    get 'marionette_movie'
    get 'marionette_slide'
  end

  namespace :sugarcoat do
    resource :bot, controller: :bot, only: [] do
      get 'speak'
      get 'callback'
      post 'callback'
      get 'linebot_callback'
      post 'linebot_callback'
    end

    resource :landing, controller: :landing, only: [] do
      get 'page'
      get 'page01'
      get 'page02'
      get 'page03'
    end
  end

  namespace :moi_voice do
    resource :oauth, controller: :oauth, only: [] do
      get 'twitcas_auth'
      get 'twitcas_callback'
    end

    resource :top, controller: :top, only: [] do
      get 'page'
    end

    resource :streaming, controller: :streaming, only: [] do
      get 'play'
    end
  end

  namespace :citore do
    resource :voice, controller: :voice, only: [] do
      get 'download'
    end

    resources :words, only: [:index] do
      collection do
        get 'search'
      end
    end
  end

  namespace :tools do
    resource :chat, controller: :chat, only: [:index] do
      get :index
    end
  end
end
