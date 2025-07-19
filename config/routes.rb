Rails.application.routes.draw do
  root "authentication#login"

  # Authentication routes
  get "login", to: "authentication#login"
  post "login", to: "authentication#authenticate"
  delete "logout", to: "authentication#logout"

  # Language switching route
  get "set_locale/:locale", to: "authentication#change_locale", as: "set_locale"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Client management with RESTful routes
  resources :clients, only: [ :index, :new, :create, :destroy ] do
    collection do
      get :fetch_wireguard_address
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
