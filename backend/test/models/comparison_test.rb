require "test_helper"

class ComparisonTest < ActiveSupport::TestCase
  setup do
    @creator = create_user(name: "Creator", spotify_user_id: "creator")
    @guest = create_user(name: "Guest", spotify_user_id: "guest")
    @creator_profile = create_ready_profile(@creator)
    @guest_profile = create_ready_profile(@guest)
  end

  test "comparison is created only for a ready music profile" do
    comparison = Comparison.create_for!(@creator)

    assert comparison.waiting?
    assert comparison.invite_token.present?

    user_without_profile = create_user(name: "No Profile", spotify_user_id: "no-profile")
    assert_raises(Comparison::Error) { Comparison.create_for!(user_without_profile) }
  end

  test "guest joins and compatibility score is calculated" do
    create_profile_item(profile: @creator_profile, type: "artist", name: "Common Artist", weight: 15)
    create_profile_item(profile: @guest_profile, type: "artist", name: "Common Artist", weight: 15)
    create_profile_item(profile: @creator_profile, type: "track", name: "Common Track", weight: 15)
    create_profile_item(profile: @guest_profile, type: "track", name: "Common Track", weight: 15)
    comparison = Comparison.create_for!(@creator)

    result = comparison.join!(@guest)

    assert comparison.completed?
    assert_equal @guest, comparison.guest
    assert_equal 7, comparison.score
    assert_equal 1, result[:common_artists].size
    assert_equal 1, result[:common_tracks].size
  end

  test "creator cannot join own comparison and completed comparison cannot be joined again" do
    comparison = Comparison.create_for!(@creator)

    assert_raises(Comparison::Error) { comparison.join!(@creator) }

    comparison.join!(@guest)
    another_user = create_user(name: "Another", spotify_user_id: "another")
    create_ready_profile(another_user)

    assert_raises(Comparison::Error) { comparison.join!(another_user) }
  end
end
