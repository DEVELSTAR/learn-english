class LessonComment < ApplicationRecord
  belongs_to :lesson
  belongs_to :user
  belongs_to :parent, class_name: "LessonComment", optional: true
  has_many :replies, -> { order(created_at: :asc) }, class_name: "LessonComment", foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 2000 }

  scope :root_comments, -> { where(parent_id: nil) }
  scope :chronological, -> { order(created_at: :asc) }
  scope :recent_first, -> { order(created_at: :desc) }

  def reply?
    parent_id.present?
  end

  def root?
    parent_id.nil?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id lesson_id user_id parent_id content created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[lesson user parent replies]
  end
end

