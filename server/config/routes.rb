Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resource :apk_downloader, controller: :apk_downloader, only: [] do
    get 'warakatsu'
    get 'citore'
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

  namespace :citore do
    resource :voice, controller: :voice, only: [] do
      get 'search'
      get 'download'
    end
  end

  namespace :tools do
    resource :chat, controller: :chat, only: [:index] do
      get :index
    end
  end
end
