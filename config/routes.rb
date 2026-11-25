Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :admin do
    root to: redirect("/admin/challenges")
    resources :challenges, except: :show
    resources :locations, except: :show
    resources :birds, except: :show do
      resources :photos, except: %i[index show]
    end
  end

  namespace :api do
    resources :challenges, only: :show do
      resource :score, only: :create
    end
  end

  root "game#show"
end
