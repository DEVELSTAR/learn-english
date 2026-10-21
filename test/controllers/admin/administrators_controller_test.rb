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

    test "super admin cannot be created from admin panel" do
      sign_in_as(@super_admin)
      assert_no_difference("User.where(role: :super_admin).count") do
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

      assert_response :unprocessable_entity
      assert_includes response.body, "Super Administrator accounts cannot be created from the admin panel."
    end

    test "super admin can view administrator details" do
      sign_in_as(@super_admin)
      get admin_administrator_path(@admin)
      assert_response :success
      assert_select "#page_title", text: @admin.name
    end

    test "super admin can view edit form for regular admin" do
      sign_in_as(@super_admin)
      get edit_admin_administrator_path(@admin)
      assert_response :success
      assert_select "#page_title", text: "Edit Administrator"
    end

    test "super admin cannot view edit form for super admin" do
      sign_in_as(@super_admin)
      get edit_admin_administrator_path(@super_admin)
      assert_redirected_to admin_administrators_path
      assert_equal "Super Administrator accounts cannot be modified from the admin panel.", flash[:alert]
    end

    test "super admin cannot update super admin from admin panel" do
      sign_in_as(@super_admin)
      original_name = @super_admin.name

      patch admin_administrator_path(@super_admin), params: {
        user: { name: "Modified Super Admin" }
      }

      assert_redirected_to admin_administrators_path
      assert_equal "Super Administrator accounts cannot be modified from the admin panel.", flash[:alert]
      assert_equal original_name, @super_admin.reload.name
    end

    test "super admin can update regular admin but cannot promote to super admin" do
      sign_in_as(@super_admin)
      patch admin_administrator_path(@admin), params: {
        user: {
          name: "Updated Teacher Admin",
          role: "super_admin",
          password: "",
          password_confirmation: ""
        }
      }

      assert_redirected_to admin_administrators_path
      @admin.reload
      assert_equal "Updated Teacher Admin", @admin.name
      assert_equal "admin", @admin.role
      assert_not @admin.super_admin?
    end

    test "super admin can delete a regular administrator" do
      sign_in_as(@super_admin)
      assert_difference("User.count", -1) do
        delete admin_administrator_path(@admin)
      end

      assert_redirected_to admin_administrators_path
    end

    test "super admin cannot delete any super admin account" do
      sign_in_as(@super_admin)
      assert_no_difference("User.count") do
        delete admin_administrator_path(@super_admin)
      end

      assert_redirected_to admin_administrators_path
      assert_equal "Super Administrator accounts cannot be deleted from the admin panel!", flash[:alert]
    end

    test "accessing student id redirects with warning" do
      sign_in_as(@super_admin)
      get admin_administrator_path(@student)
      assert_redirected_to admin_administrators_path
      assert_includes flash[:alert], "is a student, not an administrator"
    end
  end
end

