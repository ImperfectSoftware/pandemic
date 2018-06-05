Rails.application.routes.draw do
  scope '/', defaults: { format: :json } do
    resources :games, only: [:create, :update, :index] do
      resources :cure_diseases, only: :create
      resources :charter_flights, only: :create
      resources :direct_flights, only: :create
      resources :get_cards, only: :create
      resources :give_cards, only: :create
      resources :line_movements, only: :create
      resources :movement_proposals, only: [:create, :update]
      resources :operations_expert_flights, only: :create
      resources :research_stations, only: :create
      delete "/research_stations/:city_staticid", to: "research_stations#destroy"
      resources :share_cards, only: :update
      resources :shuttle_flights, only: :create
      resources :treat_diseases, only: :create

      scope module: :games, path: '' do
        resource :invitations, only: [:create, :update, :destroy]
        get :invitations, to: 'invitations#index'
        resource :discard_city_cards, only: :destroy
        resource :finish_turns, only: :create
        resource :forecasts, only: [:create, :update]
        resource :resilient_populations, only: [:show, :create]
        resource :skip_infections, only: :create
        resource :special_cards, only: [:show, :create]
        resource :stage_two_epidemics, only: :create
      end
    end
    post 'authenticate', to: 'authentication#authenticate'
  end
end
