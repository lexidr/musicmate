module Api
  module V1
    class AuthController < ApplicationController
      def spotify
        state = SecureRandom.hex(16)

        cookies.signed[:spotify_state] = {
          value: state,
          expires: 10.minutes.from_now,
          httponly: true,
          same_site: :lax
        }

        url = SpotifyClient.new.authorization_url(state: state)
        redirect_to url, allow_other_host: true
      end

      def callback
        saved_state = cookies.signed[:spotify_state]
        cookies.delete(:spotify_state)

        if saved_state.blank? || params[:state] != saved_state
          return redirect_to_frontend(error: "INVALID_OAUTH_STATE")
        end

        if params[:error].present?
          return redirect_to_frontend(error: "SPOTIFY_ACCESS_DENIED")
        end

        spotify = SpotifyClient.new
        tokens = spotify.exchange_code(params.require(:code))
        profile = spotify.current_user(tokens.fetch("access_token"))

        spotify_id = profile["account_id"] || profile["id"]
        user = User.find_or_initialize_by(spotify_user_id: spotify_id)
        user.name = profile["display_name"].presence || "Пользователь Spotify"
        user.email = profile["email"]
        user.avatar_url = profile.dig("images", 0, "url")
        user.save!

        connection = user.spotify_connection || user.build_spotify_connection
        connection.access_token = tokens.fetch("access_token")
        connection.refresh_token = tokens["refresh_token"] || connection.refresh_token
        connection.token_expires_at = Time.current + tokens.fetch("expires_in", 3600).seconds
        connection.scopes = tokens["scope"]
        connection.save!

        redirect_to_frontend(token: JwtService.encode(user))
      rescue SpotifyClient::Error, ActionController::ParameterMissing, KeyError => error
        Rails.logger.error("Spotify login error: #{error.message}")
        redirect_to_frontend(error: "SPOTIFY_LOGIN_FAILED")
      end

      def logout
        render_success({ message: "Вы вышли из аккаунта" })
      end

      private

      def redirect_to_frontend(params)
        frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:5173")
        query = URI.encode_www_form(params)

        redirect_to "#{frontend_url}/auth/callback?#{query}", allow_other_host: true
      end
    end
  end
end
