require "test_helper"

module Admin
  class AdministratorsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super_admin = users(:super_admin)
      @admin = users(:admin)
      @student = users(:student_one)
    end

    test "student is blocked from accessing administrator management" do
      sign_in_as(@student)
      get admin_administrators_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "div", text: /Access denied/
    end

    test "regular admin is blocked from accessing administrator management" do
      sign_in_as(@admin)
      get admin_administrators_path
      assert_redirected_to admin_root_path
      follow_redirect!
      assert_select "div", text: /Only Super Administrators can manage administrators/
    end

    test "super admin can view administrators list" do
      sign_in_as(@super_admin)
      get admin_administrators_path
      assert_response :success
      assert_select "#page_title", text: "Administrators"
      assert_select "td", text: @admin.name
      assert_select "td", text: @super_admin.name
    end

    test "super admin can view new administrator form" do
      sign_in_as(@super_admin)
      get new_admin_administrator_path
      assert_response :success
      assert_select "#page_title", text: "New Administrator"
    end

    test "super admin can create a regular admin" do
      sign_in_as(@super_admin)
      assert_difference("User.where(role: :admin).count", 1) do
        post admin_administrators_path, params: {
          user: {
            name: "Co-Teacher Sarah",
            email_address: "sarah@learnenglish.com",
            role: "admin",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      assert_redirected_to admin_administrators_path
      new_admin = User.find_by(email_address: "sarah@learnenglish.com")
      assert new_admin.exact_admin?
      assert new_admin.admin?
      assert_not new_admin.super_admin?
    end

    test "super admin can create a super admin" do
      sign_in_as(@super_admin)
      assert_difference("User.where(role: :super_admin).count", 1) do
        post admin_administrators_path, params: {
          user: {
            name: "Second Super Admin",
            email_address: "second_super@learnenglish.com",
            role: "super_admin",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      assert_redirected_to admin_administrators_path
      new_super = User.find_by(email_address: "second_super@learnenglish.com")
      assert new_super.super_admin?
    end

    test "super admin can view administrator details" do
      sign_in_as(@super_admin)
      get admin_administrator_path(@admin)
      assert_response :success
      assert_select "#page_title", text: @admin.name
    end

    test "super admin can view edit form" do
      sign_in_as(@super_admin)
      get edit_admin_administrator_path(@admin)
      assert_response :success
      assert_select "#page_title", text: "Edit Administrator"
    end

    test "super admin can update administrator details and promote to super admin" do
      sign_in_as(@super_admin)
      patch admin_administrator_path(@admin), params: {
        user: {
          name: "Promoted Teacher Admin",
          role: "super_admin",
          password: "",
          password_confirmation: ""
        }
      }

      assert_redirected_to admin_administrators_path
      @admin.reload
      assert_equal "Promoted Teacher Admin", @admin.name
      assert @admin.super_admin?
    end

    test "super admin can delete an administrator" do
      sign_in_as(@super_admin)
      assert_difference("User.count", -1) do
        delete admin_administrator_path(@admin)
      end

      assert_redirected_to admin_administrators_path
    end

    test "super admin cannot delete their own account" do
      sign_in_as(@super_admin)
      assert_no_difference("User.count") do
        delete admin_administrator_path(@super_admin)
      end

      assert_redirected_to admin_administrators_path
      assert_equal "You cannot delete your own account!", flash[:alert]
    end

    test "accessing student id redirects with warning" do
      sign_in_as(@super_admin)
      get admin_administrator_path(@student)
      assert_redirected_to admin_administrators_path
      assert_includes flash[:alert], "is a student, not an administrator"
    end
  end
end

