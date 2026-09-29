Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "auth/spotify", to: "auth#spotify"
      get "auth/spotify/callback", to: "auth#callback"
      get "me", to: "me#show"
      post "logout", to: "auth#logout"
      get "music-profile", to: "music_profiles#show"
      post "music-profile/sync", to: "music_profiles#sync"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
