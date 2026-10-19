class Lesson < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true
  has_rich_text :content
  has_many :lesson_completions, dependent: :destroy
  has_many :lesson_chat_messages, dependent: :destroy
  has_many :lesson_comments, dependent: :destroy
  has_many :root_lesson_comments, -> { root_comments.chronological }, class_name: "LessonComment"

  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft
  enum :lesson_type, { daily_class: 0, topic: 1 }, default: :daily_class

  validates :title, presence: true, length: { maximum: 200 }
  validates :slug, presence: true, uniqueness: true
  validates :lesson_date, presence: true
  validates :status, presence: true
  validates :lesson_type, presence: true

  before_validation :generate_slug, on: :create
  before_validation :set_default_lesson_date, on: :create

  scope :published, -> { where(status: :published) }
  scope :daily_classes, -> { where(lesson_type: :daily_class) }
  scope :topics, -> { where(lesson_type: :topic) }
  scope :ordered_topics, -> { topics.order(position: :asc, created_at: :asc) }
  scope :by_date_desc, -> { order(lesson_date: :desc, created_at: :desc) }
  scope :for_today, -> { published.daily_classes.where(lesson_date: Date.current) }

  def self.latest_published
    published.daily_classes.by_date_desc.first
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title slug lesson_date lesson_type position status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[author lesson_completions lesson_comments]
  end

  def to_param
    slug
  end

  def previous_lesson
    if topic?
      Lesson.published.topics
            .where("position < ? OR (position = ? AND id < ?)", position, position, id)
            .order(position: :desc, id: :desc)
            .first
    else
      Lesson.published.daily_classes
            .where("lesson_date < ? OR (lesson_date = ? AND id < ?)", lesson_date, lesson_date, id)
            .order(lesson_date: :desc, id: :desc)
            .first
    end
  end

  def next_lesson
    if topic?
      Lesson.published.topics
            .where("position > ? OR (position = ? AND id > ?)", position, position, id)
            .order(position: :asc, id: :asc)
            .first
    else
      Lesson.published.daily_classes
            .where("lesson_date > ? OR (lesson_date = ? AND id > ?)", lesson_date, lesson_date, id)
            .order(lesson_date: :asc, id: :asc)
            .first
    end
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

  def set_default_lesson_date
    self.lesson_date ||= Date.current
  end

  def generate_slug
    return if slug.present?
    base_slug = title.to_s.parameterize
    base_prefix = topic? ? "topic" : "lesson"
    base_slug = "#{base_prefix}-#{lesson_date || Date.current}" if base_slug.blank?
    
    candidate = base_slug
    counter = 1
    while Lesson.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
