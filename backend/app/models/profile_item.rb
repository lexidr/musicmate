class ProfileItem < ApplicationRecord
  belongs_to :music_profile

  validates :item_type, inclusion: { in: %w[artist track] }
  validates :name, :spotify_id, presence: true
end
