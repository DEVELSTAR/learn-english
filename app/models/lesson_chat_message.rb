class LessonChatMessage < ApplicationRecord
  belongs_to :lesson
  belongs_to :user

  enum :role, { user: "user", assistant: "assistant" }

  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :recent_for_context, ->(limit = 6) { order(created_at: :desc).limit(limit).reverse }
end

