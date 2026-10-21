class NoteShare < ApplicationRecord
  belongs_to :note
  belongs_to :user

  enum :status, { pending: 0, accepted: 1, declined: 2 }, default: :pending

  validates :user_id, uniqueness: { scope: :note_id, message: "has already been invited to this note" }

  scope :pending, -> { where(status: :pending) }
  scope :accepted, -> { where(status: :accepted) }
  scope :declined, -> { where(status: :declined) }
  scope :recent, -> { order(created_at: :desc) }
end

