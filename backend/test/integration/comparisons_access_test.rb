require "test_helper"

class ComparisonsAccessTest < ActionDispatch::IntegrationTest
  setup do
    @creator = create_user(name: "Creator", spotify_user_id: "creator")
    @guest = create_user(name: "Guest", spotify_user_id: "guest")
    create_ready_profile(@creator)
    create_ready_profile(@guest)
    @comparison = Comparison.create_for!(@creator)
  end

  test "unauthorized user cannot create or open comparison" do
    post "/api/v1/comparisons"
    assert_response :unauthorized
    assert_equal "UNAUTHORIZED", response_error["code"]

    get "/api/v1/comparisons/#{@comparison.invite_token}"
    assert_response :unauthorized
  end

  test "unknown invitation returns not found" do
    get "/api/v1/comparisons/unknown-token", headers: auth_headers(@creator)

    assert_response :not_found
    assert_equal "NOT_FOUND", response_error["code"]
  end

  test "outsider cannot see completed comparison" do
    @comparison.join!(@guest)
    outsider = create_user(name: "Outsider", spotify_user_id: "outsider")
    create_ready_profile(outsider)

    get "/api/v1/comparisons/#{@comparison.invite_token}", headers: auth_headers(outsider)

    assert_response :forbidden
    assert_equal "FORBIDDEN", response_error["code"]
  end
end
