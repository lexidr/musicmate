class SpotifyConnection < ApplicationRecord
  self.filter_attributes += %i[access_token refresh_token]

  belongs_to :user

  validates :access_token, presence: true
  validates :token_expires_at, presence: true

  def token_expired?
    token_expires_at.blank? || token_expires_at <= Time.current
  end

  def token_needs_refresh?
    token_expires_at.blank? || token_expires_at <= 1.minute.from_now
  end
end
