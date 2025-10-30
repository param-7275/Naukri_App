Rails.application.routes.draw do

  scope "(:locale)", locale: /en|hi|es/ do
    resources :users, only: [:show, :index]

    # Jobs Controller Routes
    get 'recruiter_index/', to: "jobs#recruiter_index", as: 'recruiter_home'
    get 'new/', to: "jobs#new", as: 'new_job'
    post 'create/', to: "jobs#create", as: 'create_new_job'
    get 'index/', to: "jobs#index", as: 'recruiter_jobs'
    get 'edit(/:id)', to: "jobs#edit", as: 'edit_job'
    match 'update(/:id)', to: "jobs#update", as: 'update_job', via: [:patch , :put]
    match 'destroy/(/:id)', to: "jobs#destroy", as: 'delete_job', via: [:delete]
    get 'recruiter_applicants', to: 'jobs#applicants', as: 'recruiter_applicants' 
    match 'change_application_status(/:id)', to: "jobs#change_application_status", as: 'change_job_status', via: [:put, :get, :patch]

    # Job Applications Controller Routes
    get 'applied_jobs/', to: "job_applications#applied_jobs", as: 'applied_jobs'
    get 'jobseeker_index/', to: "job_applications#jobseeker_index", as: 'jobseeker_home'
    get 'all_jobs/', to: "job_applications#all_jobs", as: 'all_jobs'
    get 'jobs/:job_id/job_applications/new', to: 'job_applications#new', as: 'new_job_application'
    post 'jobs/:job_id/job_applications', to: 'job_applications#create', as: 'job_applications'

    # Users Controller Routes
    match '/logout(/:id)', to: "users#destroy", as: "user_logout", via: [:get, :delete]
    get "new_signup/" , to: "users#new_signup" , as: "new_signup"
    post "user_signup/" , to: "users#user_signup" , as: "user_signup"
    get "login/" , to: "users#new_login" , as: "login"
    post "login/" , to: "users#user_login" , as: "user_login"

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Defines the root path route ("/")
    root to: "users#index"
  end
end
