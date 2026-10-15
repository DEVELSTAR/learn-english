class WordList < ApplicationRecord
  belongs_to :user
  has_many :word_entries, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: "list already exists in your lists" }

  scope :default_first, -> { order(is_default: :desc, name: :asc) }
  scope :created_by_admin, -> { joins(:user).where(users: { role: :admin }) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id name is_default created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user word_entries]
  end

  # Scopes lists visible to a specific user:
  # - User's own lists (default + custom)
  # - Any list created by an admin (shared to everyone)
  def self.visible_to(user)
    return none unless user
    joins(:user).where("word_lists.user_id = ? OR users.role = ?", user.id, User.roles[:admin]).distinct
  end

  def admin_created?
    user&.admin?
  end

  def can_manage?(current_user)
    return false unless current_user
    current_user.admin? || (!admin_created? && user_id == current_user.id)
  end
end
