class User < ApplicationRecord
  has_one :spotify_connection, dependent: :destroy
  has_one :music_profile, dependent: :destroy

  validates :name, presence: true
  validates :spotify_user_id, presence: true, uniqueness: true
end
