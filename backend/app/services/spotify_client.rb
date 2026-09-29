require "net/http"

class SpotifyClient
  AUTH_URL = "https://accounts.spotify.com/authorize"
  TOKEN_URL = "https://accounts.spotify.com/api/token"
  API_URL = "https://api.spotify.com/v1"
  SCOPES = %w[user-read-private user-read-email user-top-read].freeze

  class Error < StandardError; end

  def authorization_url(state:)
    query = URI.encode_www_form(
      client_id: client_id,
      response_type: "code",
      redirect_uri: redirect_uri,
      state: state,
      scope: SCOPES.join(" ")
    )

    "#{AUTH_URL}?#{query}"
  end

  def exchange_code(code)
    uri = URI(TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(client_id, client_secret)
    request.set_form_data(
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_uri
    )

    send_request(uri, request)
  end

  def current_user(access_token)
    uri = URI("#{API_URL}/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    send_request(uri, request)
  end

  private

  def send_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    response = http.request(request)
    raise Error, "Spotify вернул ошибку #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError
    raise Error, "Spotify вернул некорректный ответ"
  end

  def client_id
    ENV.fetch("SPOTIFY_CLIENT_ID")
  end

  def client_secret
    ENV.fetch("SPOTIFY_CLIENT_SECRET")
  end

  def redirect_uri
    ENV.fetch("SPOTIFY_REDIRECT_URI")
  end
end
