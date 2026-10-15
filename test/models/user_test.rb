require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(name: "Test", email_address: " DOWNCASED@EXAMPLE.COM ", password: "password")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "validates presence of name and email" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "creates default word lists for student on creation" do
    user = User.create!(name: "Arun", email_address: "arun@example.com", password: "password", role: :student)
    assert_equal 3, user.word_lists.count
    assert_equal ["My Words", "To Learn", "Revision"].sort, user.word_lists.pluck(:name).sort
  end

  test "does not create word lists for admin" do
    admin = User.create!(name: "Admin Two", email_address: "admintwo@example.com", password: "password", role: :admin)
    assert_equal 0, admin.word_lists.count
  end
end
