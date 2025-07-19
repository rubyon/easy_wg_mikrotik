Rails.application.routes.draw do
  root "settings#login"

  # Language switching route
  get "set_locale/:locale", to: "settings#change_locale", as: "set_locale"

  get "login", to: "settings#login"
  post "login", to: "settings#authenticate"
  delete "logout", to: "settings#logout"

  get "dashboard", to: "settings#index"
  get "new_client", to: "settings#new_client"
  post "create_client", to: "settings#create_client"
  get "clients", to: "settings#clients"
  delete "clients/:id", to: "settings#delete_client", as: "delete_client"

  get "fetch_wireguard_address", to: "settings#fetch_wireguard_address"

  get "up" => "rails/health#show", as: :rails_health_check
end
