class MusicProfile < ApplicationRecord
  belongs_to :user
  has_many :profile_items, dependent: :destroy

  validates :status, inclusion: { in: %w[empty ready failed] }
  validates :artists_count, :tracks_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def artists
    profile_items.where(item_type: "artist").order(weight: :desc)
  end

  def tracks
    profile_items.where(item_type: "track").order(weight: :desc)
  end

  def top_artists(limit = 15)
    artists.limit(limit)
  end

  def top_tracks(limit = 15)
    tracks.limit(limit)
  end

  def mark_as_ready!(artists_count:, tracks_count:)
    update!(
      status: "ready",
      artists_count: artists_count,
      tracks_count: tracks_count
    )
  end

  def mark_as_failed!
    update!(status: "failed")
  end
end
