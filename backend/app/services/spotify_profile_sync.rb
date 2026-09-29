class SpotifyProfileSync
  def initialize(user)
    @user = user
    @connection = user.spotify_connection
    @profile = user.music_profile || user.create_music_profile!
  end

  def call
    token = access_token
    spotify = SpotifyClient.new
    artists = spotify.top_items(token, "artists")
    tracks = spotify.top_items(token, "tracks")

    MusicProfile.transaction do
      profile.profile_items.delete_all
      save_artists(artists)
      save_tracks(tracks)
      profile.update!(status: "ready", artists_count: artists.size, tracks_count: tracks.size)
    end

    profile
  rescue SpotifyClient::Error
    profile.update!(status: "failed")
    raise
  end

  private

  attr_reader :connection, :profile

  def access_token
    return connection.access_token if connection.token_expires_at > 1.minute.from_now

    tokens = SpotifyClient.new.refresh_token(connection.refresh_token)
    connection.update!(
      access_token: tokens.fetch("access_token"),
      refresh_token: tokens["refresh_token"] || connection.refresh_token,
      token_expires_at: Time.current + tokens.fetch("expires_in", 3600).seconds
    )
    connection.access_token
  end

  def save_artists(artists)
    artists.each_with_index do |artist, index|
      profile.profile_items.create!(
        item_type: "artist",
        name: artist.fetch("name"),
        spotify_id: artist.fetch("id"),
        spotify_url: artist.dig("external_urls", "spotify"),
        image_url: artist.dig("images", 0, "url"),
        weight: 50 - index,
        metadata: { genres: artist["genres"] || [] }
      )
    end
  end

  def save_tracks(tracks)
    tracks.each_with_index do |track, index|
      profile.profile_items.create!(
        item_type: "track",
        name: track.fetch("name"),
        artist_name: track.fetch("artists").map { |artist| artist["name"] }.join(", "),
        spotify_id: track.fetch("id"),
        spotify_url: track.dig("external_urls", "spotify"),
        image_url: track.dig("album", "images", 0, "url"),
        weight: 50 - index
      )
    end
  end
end
