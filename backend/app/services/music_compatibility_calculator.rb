class MusicCompatibilityCalculator
  ITEMS_IN_PROFILE = 30

  def initialize(first_user, second_user)
    @first_profile = first_user.music_profile
    @second_profile = second_user.music_profile
  end

  def call
    common_artists = common_items(first_profile.top_artists, second_profile.top_artists)
    common_tracks = common_items(first_profile.top_tracks, second_profile.top_tracks)
    matches_count = common_artists.size + common_tracks.size

    {
      score: ((matches_count.to_f / ITEMS_IN_PROFILE) * 100).round,
      common_artists: items_data(common_artists),
      common_tracks: items_data(common_tracks)
    }
  end

  private

  attr_reader :first_profile, :second_profile

  def common_items(first_items, second_items)
    second_ids = second_items.pluck(:spotify_id)
    first_items.select { |item| second_ids.include?(item.spotify_id) }
  end

  def items_data(items)
    items.map do |item|
      {
        name: item.name,
        artist_name: item.artist_name,
        spotify_url: item.spotify_url,
        image_url: item.image_url
      }
    end
  end
end
