require "test_helper"

class ComparisonsHappyPathTest < ActionDispatch::IntegrationTest
  setup do
    @creator = create_user(name: "Creator", spotify_user_id: "creator")
    @guest = create_user(name: "Guest", spotify_user_id: "guest")
    @creator_profile = create_ready_profile(@creator)
    @guest_profile = create_ready_profile(@guest)

    create_profile_item(profile: @creator_profile, type: "artist", name: "Common Artist", weight: 15)
    create_profile_item(profile: @guest_profile, type: "artist", name: "Common Artist", weight: 15)
    create_profile_item(profile: @creator_profile, type: "track", name: "Common Track", weight: 15)
    create_profile_item(profile: @guest_profile, type: "track", name: "Common Track", weight: 15)
  end

  test "creator creates invitation and guest sees it" do
    post "/api/v1/comparisons", headers: auth_headers(@creator)

    assert_response :created
    invitation = response_data
    assert_equal "waiting", invitation["status"]
    assert invitation["invite_token"].present?
    assert invitation["is_creator"]

    get "/api/v1/comparisons/#{invitation['invite_token']}", headers: auth_headers(@guest)

    assert_response :success
    assert response_data["can_join"]
    assert_equal @creator.name, response_data.dig("creator", "name")
  end

  test "guest joins and receives compatibility result" do
    comparison = Comparison.create_for!(@creator)

    post "/api/v1/comparisons/#{comparison.invite_token}/join", headers: auth_headers(@guest)

    assert_response :success
    result = response_data
    assert_equal "completed", result["status"]
    assert_equal 7, result["score"]
    assert_equal @guest.name, result.dig("guest", "name")
    assert_equal ["Common Artist"], result["common_artists"].pluck("name")
    assert_equal ["Common Track"], result["common_tracks"].pluck("name")
  end

  test "creator sees completed result after guest joins" do
    comparison = Comparison.create_for!(@creator)
    comparison.join!(@guest)

    get "/api/v1/comparisons/#{comparison.invite_token}", headers: auth_headers(@creator)

    assert_response :success
    assert_equal "completed", response_data["status"]
    assert_equal 7, response_data["score"]
  end
end
