Rails.application.routes.draw do
  root "settings#index"

  get "login", to: "settings#login"
  post "login", to: "settings#authenticate"
  delete "logout", to: "settings#logout"

  get "settings", to: "settings#index"
  get "new_client", to: "settings#new_client"
  post "create_client", to: "settings#create_client"
  get "clients", to: "settings#clients"
  delete "clients/:id", to: "settings#delete_client", as: "delete_client"

  get "fetch_wireguard_address", to: "settings#fetch_wireguard_address"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
