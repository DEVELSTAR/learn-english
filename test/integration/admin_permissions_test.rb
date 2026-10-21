require "test_helper"

class AdminPermissionsTest < ActionDispatch::IntegrationTest
  setup do
    @regular_admin = users(:admin)
    @super_admin = users(:super_admin)
    @student = users(:student_one)
    @lesson = lessons(:compare_lesson)
  end

  # ==========================================
  # 1. Admin can login only admin panel
  # ==========================================

  test "admin signs in and is redirected directly to admin panel" do
    post session_path, params: {
      email_address: @regular_admin.email_address,
      password: "password"
    }

    assert_redirected_to admin_root_path
  end

  test "super admin signs in and is redirected directly to admin panel" do
    post session_path, params: {
      email_address: @super_admin.email_address,
      password: "password"
    }

    assert_redirected_to admin_root_path
  end

  test "student signs in and is redirected to root" do
    post session_path, params: {
      email_address: @student.email_address,
      password: "password"
    }

    assert_redirected_to root_url
  end

  test "regular admin cannot access home page and is redirected to admin panel" do
    sign_in_as(@regular_admin)

    get root_path
    assert_redirected_to admin_root_path
  end

  test "regular admin cannot access notes and is redirected to admin panel" do
    sign_in_as(@regular_admin)

    get notes_path
    assert_redirected_to admin_root_path
    assert_equal "Administrators can only access the Admin Panel.", flash[:alert]
  end

  test "regular admin cannot access sign in page when logged in" do
    sign_in_as(@regular_admin)

    get new_session_path
    assert_redirected_to admin_root_path
  end

  test "regular admin can preview a published lesson in read-only mode" do
    sign_in_as(@regular_admin)

    get lesson_path(@lesson)
    assert_response :success
    assert_select "span", text: "Admin Preview"
    # Interactive student features must not appear
    assert_select "#comments-section", count: 0
    assert_select "#lesson_notes_section", count: 0
    assert_select "#chat_messages_container", count: 0
    assert_select "form#chat_room_form", count: 0
  end

  # ==========================================
  # 2. Admin can't CRUD Super Admin
  # ==========================================

  test "regular admin is blocked from administrators activeadmin resource" do
    sign_in_as(@regular_admin)

    get admin_administrators_path
    assert_redirected_to admin_root_path
    assert_equal "Access denied. Only Super Administrators can manage administrators.", flash[:alert]
  end

  test "regular admin cannot view or edit super admin in activeadmin" do
    sign_in_as(@regular_admin)

    get admin_administrator_path(@super_admin)
    assert_redirected_to admin_root_path

    get edit_admin_administrator_path(@super_admin)
    assert_redirected_to admin_root_path
  end

  test "super admin can access administrators activeadmin resource" do
    sign_in_as(@super_admin)

    get admin_administrators_path
    assert_response :success
    assert_select "#page_title", text: "Administrators"
  end

  # ==========================================
  # 3. Admin can't CRUD Comments & Chat
  # ==========================================

  test "chat and comments tab does not exist on admin panel" do
    sign_in_as(@super_admin)
    get admin_root_path
    assert_response :success

    assert_select "#tabs a", text: "Comments & Chat", count: 0
    assert_select "#tabs a", text: "Lesson Comments", count: 0
  end

  test "regular admin cannot delete comments" do
    comment = LessonComment.create!(lesson: @lesson, user: @student, content: "Test comment")
    sign_in_as(@regular_admin)

    assert_no_difference("LessonComment.count") do
      delete lesson_comment_path(@lesson, comment)
    end
    assert_redirected_to admin_root_path
  end

  # ==========================================
  # 4. Admin can't CRUD Notes
  # ==========================================

  test "notes tab does not exist on admin panel" do
    sign_in_as(@super_admin)
    get admin_root_path
    assert_response :success

    assert_select "#tabs a", text: "Community Notes", count: 0
    assert_select "#tabs a", text: "Notes", count: 0
  end

  test "regular admin cannot create, edit, or delete notes" do
    note = Note.create!(user: @student, content: "Student personal study note", is_global: true)
    sign_in_as(@regular_admin)

    # Cannot create
    assert_no_difference("Note.count") do
      post notes_path, params: { note: { content: "Admin note attempt" } }
    end
    assert_redirected_to admin_root_path

    # Cannot edit
    patch note_path(note), params: { note: { content: "Admin modified note" } }
    assert_redirected_to admin_root_path
    assert_equal "Student personal study note", note.reload.content

    # Cannot delete
    assert_no_difference("Note.count") do
      delete note_path(note)
    end
    assert_redirected_to admin_root_path
  end
end
