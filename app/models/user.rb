class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :lessons, foreign_key: :author_id, dependent: :nullify
  has_many :word_lists, dependent: :destroy
  has_many :word_entries, dependent: :destroy
  has_many :lesson_completions, dependent: :destroy

  enum :role, { student: 0, admin: 1 }, default: :student

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name email_address role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[lessons word_lists word_entries lesson_completions]
  end

  after_create :create_default_word_lists, if: :student?

  private

  def create_default_word_lists
    word_lists.find_or_create_by!(name: "My Words", is_default: true)
    word_lists.find_or_create_by!(name: "To Learn", is_default: false)
    word_lists.find_or_create_by!(name: "Revision", is_default: false)
  end
end
