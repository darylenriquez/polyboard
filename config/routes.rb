Rails.application.routes.draw do
  devise_for :users
  root to: "home#index"

  resources :mailboxes do
    resources :inboxes, only: [:show]

    resources :tokens, only: [:create, :update]
    resources :mails, except: [:index, :destroy, :create, :new] do
      member do
        get 'download'
        get 'compose'
        post 'deliver'
      end
    end
  end

  resources :tokens, only: [:create, :update]

  get "/auth/:provider/callback" => 'tokens#create' # callback for authorization
end
