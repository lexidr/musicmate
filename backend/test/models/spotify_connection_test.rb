require "test_helper"

class SpotifyConnectionTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "token is expired when expiration time is in the past" do
    connection = @user.build_spotify_connection(
      access_token: "token",
      token_expires_at: 1.minute.ago
    )

    assert connection.token_expired?
    assert connection.token_needs_refresh?
  end

  test "token needs refresh when it expires in less than one minute" do
    connection = @user.build_spotify_connection(
      access_token: "token",
      token_expires_at: 30.seconds.from_now
    )

    assert_not connection.token_expired?
    assert connection.token_needs_refresh?
  end

  test "active token does not need refresh" do
    connection = @user.build_spotify_connection(
      access_token: "token",
      token_expires_at: 1.hour.from_now
    )

    assert_not connection.token_expired?
    assert_not connection.token_needs_refresh?
  end
end
