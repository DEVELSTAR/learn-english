require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @student = users(:student_one)
    end

    test "student is blocked from admin dashboard" do
      sign_in_as(@student)
      get admin_root_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "div", text: /Access denied/
    end

    test "admin can view admin dashboard" do
      sign_in_as(@admin)
      get admin_root_path
      assert_response :success
      assert_select "#page_title", text: "Dashboard"
      assert_select "strong", text: /Total Registered Students/
      assert_select "strong", text: /Published Lessons/
    end
  end
end

