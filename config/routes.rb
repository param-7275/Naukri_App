Rails.application.routes.draw do
  devise_for :users

  resources :jobs do
    resources :job_applications, only: [:new, :create]
  end

  resources :job_applications, only: [:index] # jobseeker's "My Jobs"
  resources :users, only: [:show, :index]

  root "jobs#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
