Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Bible Application Routes
  root "bible#index"

  # Main Bible interface routes
  get "books/:book_id", to: "bible#show_book", as: :bible_book
  get "books/:book_id/chapters/:chapter_number", to: "bible#show_chapter", as: :bible_chapter
  get "books/:book_id/chapters/:chapter_number/verses/:verse_number", to: "bible#show_verse", as: :bible_verse



  # Slideshow/Presentation mode
  get "slideshow/:book_id/:chapter_number/:verse_number", to: "bible#slideshow", as: :bible_slideshow

  # Interlinear text partial (for AJAX loading)
  get "books/:book_id/chapters/:chapter_number/verses/:verse_number/interlinear", to: "bible#interlinear", as: :bible_interlinear

  # Search functionality
  get "search", to: "bible#search", as: :bible_search

  # Strong's concordance definitions
  get "strongs/:strong_number", to: "bible#strong_definition", as: :strong_definition

  # Settings management with Turbo
  resource :settings, only: [ :show, :update ] do
    patch :reset, on: :member
    get :close, on: :member
  end

  # Hotwire-based interactions - no API needed
end
