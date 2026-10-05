module Api
  module V1
    class MusicProfilesController < ApplicationController
      before_action :authenticate_user!

      def show
        profile = current_user.music_profile_or_create!
        render_success(profile_data(profile))
      end

      def sync
        profile = SpotifyProfileSync.new(current_user).call
        render_success(profile_data(profile))
      rescue SpotifyClient::Error => error
        render_error("SPOTIFY_ERROR", error.message, status: :bad_gateway)
      end

      private

      def profile_data(profile)
        {
          status: profile.status,
          artists_count: profile.artists_count,
          tracks_count: profile.tracks_count,
          artists: items_data(profile, "artist"),
          tracks: items_data(profile, "track")
        }
      end

      def items_data(profile, type)
        items = type == "artist" ? profile.artists : profile.tracks

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
  end
end
