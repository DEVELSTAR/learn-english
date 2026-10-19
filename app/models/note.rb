class Note < ApplicationRecord
  belongs_to :user

  normalizes :title, with: ->(t) { t&.strip }
  normalizes :content, with: ->(c) { c&.strip }

  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true, length: { minimum: 2, maximum: 10_000 }

  scope :recent, -> { order(updated_at: :desc, created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id title content user_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
