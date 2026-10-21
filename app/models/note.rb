class Note < ApplicationRecord
  belongs_to :user
  belongs_to :lesson, optional: true

  has_many :note_shares, dependent: :destroy
  has_many :shared_users, through: :note_shares, source: :user

  normalizes :content, with: ->(c) { c&.strip }

  validates :content, presence: true, length: { minimum: 2, maximum: 10_000 }

  scope :recent, -> { order(updated_at: :desc, created_at: :desc) }
  scope :global, -> { where(is_global: true) }
  scope :general, -> { where(lesson_id: nil) }
  scope :for_lesson, ->(lesson) { where(lesson: lesson) }

  scope :visible_to, ->(user) {
    if user&.super_admin?
      all
    elsif user.blank? || user.regular_admin?
      where(is_global: true)
    else
      where(is_global: true)
        .or(where(user_id: user.id))
        .or(where(id: NoteShare.where(user_id: user.id, status: :accepted).select(:note_id)))
    end
  }

  def can_view?(viewer)
    return true if is_global?
    return false unless viewer
    return true if viewer.super_admin? || user_id == viewer.id

    note_shares.where(user_id: viewer.id, status: :accepted).exists?
  end

  def can_edit?(editor)
    return false unless editor
    return true if editor.super_admin? || user_id == editor.id

    note_shares.where(user_id: editor.id, can_edit: true, status: :accepted).exists?
  end

  def can_delete?(deleter)
    return false unless deleter
    deleter.super_admin? || user_id == deleter.id
  end

  def pending_invitation_for?(target_user)
    return false unless target_user
    note_shares.where(user_id: target_user.id, status: :pending).exists?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id content user_id lesson_id is_global created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user lesson note_shares shared_users]
  end
end
