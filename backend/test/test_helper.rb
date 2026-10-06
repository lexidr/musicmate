ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "minitest/autorun"
require "active_support/test_case"

class ActiveSupport::TestCase
  teardown do
    ProfileItem.delete_all
    MusicProfile.delete_all
    SpotifyConnection.delete_all
    User.delete_all
  end

  def create_user
    User.create!(
      name: "Test User",
      spotify_user_id: "test-spotify-user"
    )
  end

  def create_profile(user = create_user)
    user.create_music_profile!
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
