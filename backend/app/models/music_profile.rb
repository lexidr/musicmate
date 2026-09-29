class MusicProfile < ApplicationRecord
  belongs_to :user
  has_many :profile_items, dependent: :destroy

  validates :status, inclusion: { in: %w[empty ready failed] }
end
