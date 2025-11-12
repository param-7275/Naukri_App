# frozen_string_literal: true

require 'sidekiq/web'
Rails.application.routes.draw do
  get 'webhooks/stripe'
  scope '(:locale)', locale: /en|hi/ do
    mount Sidekiq::Web => '/sidekiq'

    # Jobs Controller Routes
    get 'recruiter_index/', to: 'jobs#recruiter_index', as: 'recruiter_home'
    get 'new/', to: 'jobs#new', as: 'new_job'
    post 'create/', to: 'jobs#create', as: 'create_new_job'
    get 'index/', to: 'jobs#index', as: 'recruiter_jobs'
    get 'edit/:id', to: 'jobs#edit', as: 'edit_job'
    match '/update(/:id)', to: 'jobs#update', as: 'update_job', via: %i[get put patch]
    match '/destroy(/:id)', to: 'jobs#destroy', as: 'delete_job', via: [:delete]
    get 'recruiter_applicants', to: 'jobs#applicants', as: 'recruiter_applicants'
    get 'view_job_description/(:id)', to: 'jobs#view_job_description', as: 'job_description'
    get 'generate_ai_description', to: 'jobs#ai_description', as: 'generate_ai_description'


    # Job Applications Controller Routes
    get 'applied_jobs/', to: 'job_applications#applied_jobs', as: 'applied_jobs'
    get 'jobseeker_index/', to: 'job_applications#jobseeker_index', as: 'jobseeker_home'
    get 'all_jobs/', to: 'job_applications#all_jobs', as: 'all_jobs'
    get  'job_applications/new/:job_id', to: 'job_applications#new', as: 'new_job_application'
    post 'job_applications/create/:job_id', to: 'job_applications#create', as: 'job_applications'
    match 'change_application_status/:id', to: 'job_applications#change_application_status', as: 'change_job_status',
                                           via: %i[patch put]
    get 'plan_and_pricing/', to: 'job_applications#plan_and_pricing', as: 'pricing'

    get 'job_applications/:id/reapply/edit', to: 'job_applications#edit_reapply', as: 'edit_reapply_application'
    patch 'job_applications/:id/reapply', to: 'job_applications#reapply_application', as: 'reapply_application'
    get 'job_applications/:id/view_employee_details', to: 'job_applications#view_employee_details',
                                                      as: 'view_employee_details'

    # Users Controller Routes
    match '/logout(/:id)', to: 'users#destroy', as: 'user_logout', via: %i[get delete]
    get 'new_signup/', to: 'users#new_signup', as: 'new_signup'
    post 'user_signup/', to: 'users#user_signup', as: 'user_signup'
    get 'login/', to: 'users#new_login', as: 'login'
    post 'login/', to: 'users#user_login', as: 'user_login'

    # Subscriptions Controller Routes

    # get 'subscriptions/new', to: "subscriptions#new", as: :new_subscription
    # post 'create/', to: "subscriptions#create", as: 'create_subscription'

    # If you want to use stripe checkout
    resources :subscriptions, only: %i[new create] do
      collection do
        get 'success', to: 'subscriptions#success', as: :success
        get 'cancel',  to: 'subscriptions#cancel',  as: :cancel
        get 'plan_details', to: 'subscriptions#plan_details', as: :user_plan_details_subscriptions
      end
    end

    # Webhook Controller Routes

    post '/webhooks/stripe', to: 'webhooks#stripe'

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get 'up' => 'rails/health#show', as: :rails_health_check

    # Defines the root path route ("/")
    root to: 'users#index'
  end
end
