class User < ApplicationRecord
  has_one :spotify_connection, dependent: :destroy
  has_one :music_profile, dependent: :destroy
  has_many :created_comparisons,
    class_name: "Comparison",
    foreign_key: :creator_id,
    dependent: :destroy,
    inverse_of: :creator
  has_many :joined_comparisons,
    class_name: "Comparison",
    foreign_key: :guest_id,
    dependent: :destroy,
    inverse_of: :guest

  validates :name, presence: true
  validates :spotify_user_id, presence: true, uniqueness: true

  def music_profile_or_create!
    music_profile || create_music_profile!
  end
end
