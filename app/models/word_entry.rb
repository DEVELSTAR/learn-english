class WordEntry < ApplicationRecord
  belongs_to :user
  belongs_to :word_list
  belongs_to :lesson, optional: true

  attr_accessor :bulk_words

  enum :status, { new_word: 0, learning: 1, learned: 2 }, default: :new_word

  validates :term, presence: true, length: { maximum: 200 }
  validates :term, uniqueness: { 
    scope: :word_list_id, 
    case_sensitive: false, 
    message: "is already in this list" 
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :needs_revision, -> { where(needs_revision: true) }
  scope :in_progress, -> { where(status: [:new_word, :learning]) }
  scope :due_for_revision, -> { where(needs_revision: true).or(where(status: [:new_word, :learning])).order(updated_at: :asc) }

  scope :search, ->(query) {
    if query.present?
      sanitized = "%#{query.strip.downcase}%"
      where("LOWER(term) LIKE ? OR LOWER(COALESCE(personal_note, '')) LIKE ?", sanitized, sanitized)
    else
      all
    end
  }

  def mark_reviewed!
    update!(last_reviewed_at: Time.current)
  end
end

