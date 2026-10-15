require "test_helper"

module Admin
  class StudentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @student = users(:student_one)
    end

    test "student is blocked from accessing student management" do
      sign_in_as(@student)
      get admin_students_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "div", text: /Access denied/
    end

    test "admin can view students list" do
      sign_in_as(@admin)
      get admin_students_path
      assert_response :success
      assert_select "#page_title", text: "Students"
      assert_select "td", text: @student.name
    end

    test "admin can filter students by query" do
      sign_in_as(@admin)
      get admin_students_path, params: { q: { name_cont: "Rahul" } }
      assert_response :success
      assert_select "td", text: "Rahul Sharma"
      assert_select "td", text: "Priya Patel", count: 0
    end

    test "admin can view new student form" do
      sign_in_as(@admin)
      get new_admin_student_path
      assert_response :success
      assert_select "#page_title", text: "New Student"
    end

    test "admin can create a student" do
      sign_in_as(@admin)
      assert_difference("User.where(role: :student).count", 1) do
        post admin_students_path, params: {
          user: {
            name: "Ananya Roy",
            email_address: "ananya@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      assert_redirected_to admin_students_path
      assert_equal "Student was successfully created.", flash[:notice]

      new_student = User.find_by(email_address: "ananya@example.com")
      assert_equal "student", new_student.role
    end

    test "admin can view student show details" do
      sign_in_as(@admin)
      get admin_student_path(@student)
      assert_response :success
      assert_select "#page_title", text: @student.name
    end

    test "admin can view student edit form" do
      sign_in_as(@admin)
      get edit_admin_student_path(@student)
      assert_response :success
      assert_select "#page_title", text: "Edit Student"
    end

    test "admin can update student name and email" do
      sign_in_as(@admin)
      patch admin_student_path(@student), params: {
        user: {
          name: "Rahul S. Sharma",
          email_address: "rahul.sharma@example.com",
          password: "",
          password_confirmation: ""
        }
      }

      assert_redirected_to admin_students_path
      @student.reload
      assert_equal "Rahul S. Sharma", @student.name
      assert_equal "rahul.sharma@example.com", @student.email_address
    end

    test "admin can delete a student" do
      sign_in_as(@admin)
      assert_difference("User.count", -1) do
        delete admin_student_path(@student)
      end
      assert_redirected_to admin_students_path
    end

    test "admin accessing admin user id in students controller redirects gracefully" do
      sign_in_as(@admin)
      get admin_student_path(@admin)
      assert_redirected_to admin_students_path
      assert_includes flash[:alert], "is an administrator, not a student"
    end
  end
end

