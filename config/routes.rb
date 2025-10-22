Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "application#index"

  # Resources page
  get "resources", to: "application#resources"

  # Redirects from old principle URLs to new ones (permanent 301 redirects)
  get "/reflection", to: redirect("/principles/human-wellbeing", status: 301)
  get "/inclusivity", to: redirect("/principles/inclusive-creation", status: 301)
  get "/empowerment", to: redirect("/principles/open-infrastructure", status: 301)
  get "/privacy", to: redirect("/principles/data-sovereignity", status: 301)
  get "/transparency", to: redirect("/principles/transparent-algorithms", status: 301)
  get "/climate", to: redirect("/principles/lower-environmental-impact", status: 301)
  get "/shared-value", to: redirect("/principles/governance-for-the-common-good", status: 301)

  # Dynamic principle pages
  get "principles/:id", to: "principles#show", as: :principle

  # Signature collection routes - main entry at /sign
  get "sign", to: "signatures#new", as: :sign
  resources :signatures, only: [ :index, :create, :edit, :update ] do
    collection do
      get :verify
      post :confirm
      get :resend_code
    end
  end

  # Contact form
  get "contact", to: "contacts#new", as: :contact
  post "contact", to: "contacts#create"
  get "contact/success", to: "contacts#success", as: :contact_success
end
