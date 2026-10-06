require "test_helper"

class MusicProfileTest < ActiveSupport::TestCase
  setup do
    @profile = create_profile
  end

  test "artists and tracks are separated and ordered by weight" do
    create_profile_item(profile: @profile, type: "artist", name: "Second Artist", weight: 10)
    create_profile_item(profile: @profile, type: "artist", name: "First Artist", weight: 20)
    create_profile_item(profile: @profile, type: "track", name: "First Track", weight: 30)

    assert_equal ["First Artist", "Second Artist"], @profile.artists.pluck(:name)
    assert_equal ["First Track"], @profile.tracks.pluck(:name)
  end

  test "top methods return no more than fifteen items" do
    17.times do |index|
      create_profile_item(
        profile: @profile,
        type: "artist",
        name: "Artist #{index}",
        weight: index
      )
      create_profile_item(
        profile: @profile,
        type: "track",
        name: "Track #{index}",
        weight: index
      )
    end

    assert_equal 15, @profile.top_artists.count
    assert_equal 15, @profile.top_tracks.count
  end

  test "profile can be marked as ready and failed" do
    @profile.mark_as_ready!(artists_count: 25, tracks_count: 50)

    assert_equal "ready", @profile.status
    assert_equal 25, @profile.artists_count
    assert_equal 50, @profile.tracks_count

    @profile.mark_as_failed!

    assert_equal "failed", @profile.status
  end
end
