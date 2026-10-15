require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_path
    assert_response :success
  end

  test "should create student user and default word lists" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        user: {
          name: "New Student",
          email_address: "newstudent@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    new_user = User.find_by(email_address: "newstudent@example.com")
    assert_not_nil new_user
    assert new_user.student?
    assert_equal 3, new_user.word_lists.count
    assert_not_nil new_user.word_lists.find_by(name: "My Words", is_default: true)
    assert_not_nil new_user.word_lists.find_by(name: "To Learn")
    assert_not_nil new_user.word_lists.find_by(name: "Revision")

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "cannot register with mismatched passwords" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          name: "Test",
          email_address: "fail@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end

