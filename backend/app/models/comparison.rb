class Comparison < ApplicationRecord
  class Error < StandardError; end

  belongs_to :creator, class_name: "User"
  belongs_to :guest, class_name: "User", optional: true

  before_validation :set_invite_token, on: :create

  validates :invite_token, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[waiting completed] }
  validates :score,
    numericality: { only_integer: true, in: 0..100 },
    allow_nil: true
  validate :users_must_be_different

  def self.create_for!(user)
    raise Error, "Сначала создайте музыкальный профиль" unless profile_ready?(user)

    create!(creator: user)
  end

  def waiting?
    status == "waiting"
  end

  def completed?
    status == "completed"
  end

  def join!(user)
    raise Error, "Нельзя сравнить профиль с самим собой" if user == creator
    raise Error, "К этому сравнению уже присоединился другой пользователь" unless waiting?
    raise Error, "Сначала создайте музыкальный профиль" unless self.class.profile_ready?(user)

    calculation = MusicCompatibilityCalculator.new(creator, user).call
    update!(guest: user, status: "completed", score: calculation[:score])
    calculation
  end

  def result
    return unless completed?

    MusicCompatibilityCalculator.new(creator, guest).call
  end

  def participant?(user)
    creator == user || guest == user
  end

  def self.profile_ready?(user)
    user.music_profile&.status == "ready"
  end

  private

  def set_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(12)
  end

  def users_must_be_different
    errors.add(:guest, "не может совпадать с создателем") if guest.present? && guest == creator
  end
end
