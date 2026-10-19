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

  test "role helper methods work correctly" do
    super_admin = users(:super_admin)
    admin = users(:admin)
    student = users(:student_one)

    assert super_admin.super_admin?
    assert super_admin.admin?
    assert_not super_admin.regular_admin?
    assert_not super_admin.student?

    assert_not admin.super_admin?
    assert admin.admin?
    assert admin.regular_admin?
    assert_not admin.student?

    assert_not student.super_admin?
    assert_not student.admin?
    assert_not student.regular_admin?
    assert student.student?
  end
end
