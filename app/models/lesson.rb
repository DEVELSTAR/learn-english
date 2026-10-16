class Lesson < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true
  has_rich_text :content
  has_many :lesson_completions, dependent: :destroy
  has_many :word_entries, dependent: :nullify
  has_many :lesson_chat_messages, dependent: :destroy

  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft

  validates :title, presence: true, length: { maximum: 200 }
  validates :slug, presence: true, uniqueness: true
  validates :lesson_date, presence: true
  validates :status, presence: true

  before_validation :generate_slug, on: :create

  scope :published, -> { where(status: :published) }
  scope :by_date_desc, -> { order(lesson_date: :desc, created_at: :desc) }
  scope :for_today, -> { published.where(lesson_date: Date.current) }
  scope :latest_published, -> { published.by_date_desc.first }

  def self.ransackable_attributes(auth_object = nil)
    %w[id title slug lesson_date status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[author lesson_completions word_entries]
  end

  def to_param
    slug
  end

  def previous_lesson
    Lesson.published
          .where("lesson_date < ? OR (lesson_date = ? AND id < ?)", lesson_date, lesson_date, id)
          .order(lesson_date: :desc, id: :desc)
          .first
  end

  def next_lesson
    Lesson.published
          .where("lesson_date > ? OR (lesson_date = ? AND id > ?)", lesson_date, lesson_date, id)
          .order(lesson_date: :asc, id: :asc)
          .first
  end

  def completed_by?(user)
    return false unless user
    lesson_completions.exists?(user: user, completed: true)
  end

  def needs_revision_for?(user)
    return false unless user
    lesson_completions.exists?(user: user, needs_revision: true)
  end

  private

  def generate_slug
    return if slug.present?
    base_slug = title.to_s.parameterize
    base_slug = "lesson-#{lesson_date || Date.current}" if base_slug.blank?
    
    candidate = base_slug
    counter = 1
    while Lesson.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end

