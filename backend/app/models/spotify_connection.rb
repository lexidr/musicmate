class SpotifyConnection < ApplicationRecord
  self.filter_attributes += %i[access_token refresh_token]

  belongs_to :user

  validates :access_token, presence: true
end
