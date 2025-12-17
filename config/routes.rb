Rails.application.routes.draw do
  devise_for :users
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index', as: :dashboard
  
  # Notes
  resources :notes
  
  # Calendar Events
  resources :calendar_events
  
  # Projects with nested resources
  resources :projects do
    member do
      patch :archive
      patch :unarchive
    end
    
    resources :tasks do
      member do
        patch :complete
        patch :uncomplete
      end
    end
    
    resources :categories
  end
  
  # AI Suggestions
  resources :ai_suggestions, only: [:index, :create, :destroy]
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
end
