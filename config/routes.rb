Rails.application.routes.draw do
  resources :games, only: [:create, :update], format: :json do
    resources :cure_diseases, only: :create, format: :json
    resources :charter_flights, only: :create, format: :json
    resources :direct_flights, only: :create, format: :json
    resources :forecasts, only: :create, format: :json
    resources :get_cards, only: :create, format: :json
    resources :give_cards, only: :create, format: :json
    resources :invitations, only: [:create, :update, :destroy], format: :json
    resources :line_movements, only: :create, format: :json
    resources :movement_proposals, only: [:create, :update], format: :json
    resources :operations_expert_flights, only: :create, format: :json
    resources :research_stations, only: :create, format: :json
    resources :share_cards, only: :update, format: :json
    resources :shuttle_flights, only: :create, format: :json
    resources :treat_diseases, only: :create, format: :json

    scope module: :games, path: '' do
      resource :skip_infections, only: :create
    end
  end
  post 'authenticate', to: 'authentication#authenticate'
end
