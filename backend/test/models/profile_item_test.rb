require "test_helper"

class ProfileItemTest < ActiveSupport::TestCase
  setup do
    @profile = create_profile
  end

  test "artist item identifies itself as artist" do
    item = create_profile_item(
      profile: @profile,
      type: "artist",
      name: "Test Artist",
      weight: 10
    )

    assert item.artist?
    assert_not item.track?
  end

  test "track item identifies itself as track" do
    item = create_profile_item(
      profile: @profile,
      type: "track",
      name: "Test Track",
      weight: 10
    )

    assert item.track?
    assert_not item.artist?
  end

  test "track requires artist name" do
    item = @profile.profile_items.build(
      item_type: "track",
      name: "Test Track",
      spotify_id: "test-track",
      weight: 10
    )

    assert_not item.valid?
    assert_includes item.errors[:artist_name], "can't be blank"
  end
end
