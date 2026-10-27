ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "minitest/autorun"
require "active_support/test_case"
require "action_dispatch/testing/integration"

class ActiveSupport::TestCase
  teardown do
    Comparison.delete_all
    ProfileItem.delete_all
    MusicProfile.delete_all
    SpotifyConnection.delete_all
    User.delete_all
  end

  def create_user(name: "Test User", spotify_user_id: "test-spotify-user")
    User.create!(
      name: name,
      spotify_user_id: spotify_user_id
    )
  end

  def create_profile(user = create_user)
    user.create_music_profile!
  end

  def create_ready_profile(user)
    profile = create_profile(user)
    profile.mark_as_ready!(artists_count: 15, tracks_count: 15)
    profile
  end

  def create_profile_item(profile:, type:, name:, weight:)
    profile.profile_items.create!(
      item_type: type,
      name: name,
      artist_name: type == "track" ? "Test Artist" : nil,
      spotify_id: "#{type}-#{name.parameterize}",
      weight: weight
    )
  end
end

class ActionDispatch::IntegrationTest
  def auth_headers(user)
    { "Authorization" => "Bearer #{JwtService.encode(user)}" }
  end

  def response_data
    JSON.parse(response.body).fetch("data")
  end

  def response_error
    JSON.parse(response.body).fetch("error")
  end
end
