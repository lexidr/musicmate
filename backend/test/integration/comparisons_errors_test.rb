require "test_helper"

class ComparisonsErrorsTest < ActionDispatch::IntegrationTest
  setup do
    @creator = create_user(name: "Creator", spotify_user_id: "creator")
    @guest = create_user(name: "Guest", spotify_user_id: "guest")
    create_ready_profile(@creator)
    create_ready_profile(@guest)
    @comparison = Comparison.create_for!(@creator)
  end

  test "user without music profile cannot create comparison" do
    user = create_user(name: "No Profile", spotify_user_id: "no-profile")

    post "/api/v1/comparisons", headers: auth_headers(user)

    assert_response :unprocessable_entity
    assert_equal "COMPARISON_ERROR", response_error["code"]
  end

  test "creator cannot join own comparison" do
    post "/api/v1/comparisons/#{@comparison.invite_token}/join", headers: auth_headers(@creator)

    assert_response :unprocessable_entity
    assert_equal "COMPARISON_ERROR", response_error["code"]
    assert @comparison.reload.waiting?
  end

  test "another user cannot join completed comparison" do
    @comparison.join!(@guest)
    another_user = create_user(name: "Another", spotify_user_id: "another")
    create_ready_profile(another_user)

    post "/api/v1/comparisons/#{@comparison.invite_token}/join", headers: auth_headers(another_user)

    assert_response :unprocessable_entity
    assert_equal "COMPARISON_ERROR", response_error["code"]
    assert_equal @guest, @comparison.reload.guest
  end
end
