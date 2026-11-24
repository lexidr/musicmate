require "test_helper"

class ComparisonsHistoryTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user(name: "User", spotify_user_id: "user")
    @friend = create_user(name: "Friend", spotify_user_id: "friend")
    @second_friend = create_user(name: "Second Friend", spotify_user_id: "second-friend")

    create_ready_profile(@user)
    create_ready_profile(@friend)
    create_ready_profile(@second_friend)
  end

  test "history contains comparisons where user was creator or guest" do
    created_comparison = Comparison.create_for!(@user)
    created_comparison.join!(@friend)

    joined_comparison = Comparison.create_for!(@second_friend)
    joined_comparison.join!(@user)

    get "/api/v1/comparisons", headers: auth_headers(@user)

    assert_response :success
    assert_equal 2, response_data.size
    assert_equal [joined_comparison.invite_token, created_comparison.invite_token], response_data.pluck("invite_token")
    assert_equal @second_friend.name, response_data.first.dig("other_user", "name")
    assert_equal @friend.name, response_data.last.dig("other_user", "name")
  end

  test "history does not contain waiting and other users comparisons" do
    Comparison.create_for!(@user)

    outsider = create_user(name: "Outsider", spotify_user_id: "outsider")
    create_ready_profile(outsider)
    other_comparison = Comparison.create_for!(@friend)
    other_comparison.join!(outsider)

    get "/api/v1/comparisons", headers: auth_headers(@user)

    assert_response :success
    assert_empty response_data
  end

  test "unauthorized user cannot open history" do
    get "/api/v1/comparisons"

    assert_response :unauthorized
    assert_equal "UNAUTHORIZED", response_error["code"]
  end
end
