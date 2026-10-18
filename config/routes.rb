Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "tickets#index"

  resources :tickets, only: [:index, :show, :create] do
    member do
      post :assign
      post :reply_agent
      post :reply_customer
      post :resolve
      post :simulate_time
    end
  end
end
