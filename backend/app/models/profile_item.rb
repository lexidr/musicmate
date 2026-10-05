class ProfileItem < ApplicationRecord
  belongs_to :music_profile

  validates :item_type, inclusion: { in: %w[artist track] }
  validates :name, :spotify_id, presence: true
  validates :weight, presence: true,
    numericality: { only_integer: true }
  validates :artist_name, presence: true, if: :track?

  def artist?
    item_type == "artist"
  end

  def track?
    item_type == "track"
  end
end
