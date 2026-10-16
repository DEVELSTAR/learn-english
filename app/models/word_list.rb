class WordList < ApplicationRecord
  belongs_to :user
  has_many :word_entries, dependent: :destroy
  has_many :word_list_chat_messages, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false, message: "list already exists in your lists" }

  scope :default_first, -> { order(is_default: :desc, name: :asc) }
  scope :created_by_admin, -> { joins(:user).where(users: { role: [User.roles[:admin], User.roles[:super_admin]] }) }

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
    joins(:user).where("word_lists.user_id = :uid OR users.role IN (:roles)", uid: user.id, roles: [User.roles[:admin], User.roles[:super_admin]]).distinct
  end

  def admin_created?
    user&.admin?
  end

  attr_accessor :initial_words

  def can_manage?(current_user)
    return false unless current_user
    current_user.admin? || (!admin_created? && user_id == current_user.id)
  end

  def add_words_from_text(raw_text, user:)
    return 0 if raw_text.blank?

    count = 0
    raw_text.to_s.each_line do |line|
      cleaned = line.strip
      next if cleaned.blank?

      term, note = if cleaned.include?(":")
                     cleaned.split(":", 2).map(&:strip)
                   elsif cleaned.include?(" - ")
                     cleaned.split(" - ", 2).map(&:strip)
                   elsif cleaned.include?("|")
                     cleaned.split("|", 2).map(&:strip)
                   else
                     [ cleaned, "" ]
                   end

      next if term.blank?

      entry = word_entries.where("LOWER(term) = ?", term.downcase).first || word_entries.build(term: term)
      entry.user = user
      entry.personal_note = note if note.present?
      count += 1 if entry.save
    end

    count
  end
end
