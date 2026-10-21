require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student_one)
    @other_student = users(:student_two)
    @admin = users(:admin)
    @super_admin = users(:super_admin)
    @lesson = lessons(:compare_lesson)
  end

  test "unauthenticated user can view notes index" do
    get notes_path
    assert_response :success
    assert_includes response.body, "Notes"
  end

  test "unauthenticated user cannot create note" do
    assert_no_difference("Note.count") do
      post notes_path, params: {
        note: { content: "Unauthenticated note content." }
      }
    end
    assert_redirected_to new_session_path
  end

  test "authenticated student can create default global note" do
    sign_in_as(@student)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          content: "1. Where is the check-in counter?\n2. Could you please show me your boarding pass?"
        }
      }
    end

    note = Note.last
    assert_equal @student, note.user
    assert_nil note.lesson_id
    assert_equal true, note.is_global?
    assert_includes note.content, "Where is the check-in counter?"
    assert_redirected_to notes_path
  end

  test "authenticated student can create note attached to a lesson" do
    sign_in_as(@student)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          lesson_id: @lesson.id,
          content: "Notes specific to lesson #{@lesson.title}."
        }
      }
    end

    note = Note.last
    assert_equal @student, note.user
    assert_equal @lesson.id, note.lesson_id
    assert_equal true, note.is_global?
    assert_redirected_to lesson_path(@lesson, anchor: "lesson_notes_section")
  end

  test "can create note via turbo stream" do
    sign_in_as(@student)

    assert_difference("Note.count", 1) do
      post notes_path,
           params: { note: { content: "Sentence 1\nSentence 2\nSentence 3" } },
           as: :turbo_stream
    end

    assert_response :success
    assert_includes response.body, "turbo-stream"
    assert_includes response.body, "Sentence 1"
  end

  test "author can edit their note" do
    note = Note.create!(user: @student, content: "Original content", is_global: true)
    sign_in_as(@student)

    get edit_note_path(note), as: :turbo_stream
    assert_response :success
    assert_includes response.body, "Original content"

    patch note_path(note), params: {
      note: { content: "Updated content by author" }
    }
    assert_redirected_to notes_path

    note.reload
    assert_equal "Updated content by author", note.content
  end

  test "can update note via turbo stream" do
    note = Note.create!(user: @student, content: "Before turbo update", is_global: true)
    sign_in_as(@student)

    patch note_path(note),
          params: { note: { content: "After turbo update" } },
          as: :turbo_stream
    assert_response :success
    assert_includes response.body, "After turbo update"

    note.reload
    assert_equal "After turbo update", note.content
  end

  test "unauthorized student cannot edit another student note without permission" do
    note = Note.create!(user: @student, content: "Sentence added by student one.", is_global: true)
    sign_in_as(@other_student)

    patch note_path(note), params: {
      note: { content: "Attempted edit without permission." }
    }
    assert_redirected_to notes_path
    assert_equal "You are not authorized to edit this note.", flash[:alert]

    note.reload
    assert_equal "Sentence added by student one.", note.content
  end

  test "shared student can edit note when can_edit is true and invitation accepted" do
    note = Note.create!(user: @student, content: "Shared note content", is_global: false)
    NoteShare.create!(note: note, user: @other_student, can_edit: true, status: :accepted)

    sign_in_as(@other_student)
    patch note_path(note), params: {
      note: { content: "Edited by shared student with edit rights." }
    }
    assert_redirected_to notes_path
    assert_equal "Note updated!", flash[:notice]

    note.reload
    assert_equal "Edited by shared student with edit rights.", note.content
  end

  test "shared student cannot edit note when can_edit is false" do
    note = Note.create!(user: @student, content: "View-only shared note", is_global: false)
    NoteShare.create!(note: note, user: @other_student, can_edit: false, status: :accepted)

    sign_in_as(@other_student)
    patch note_path(note), params: {
      note: { content: "Attempting unauthorized update" }
    }
    assert_redirected_to notes_path
    assert_equal "You are not authorized to edit this note.", flash[:alert]

    note.reload
    assert_equal "View-only shared note", note.content
  end

  test "regular admin cannot access notes and is redirected to admin panel" do
    sign_in_as(@admin)
    get notes_path
    assert_redirected_to admin_root_path
    assert_equal "Administrators can only access the Admin Panel.", flash[:alert]
  end

  test "regular admin cannot edit or delete note" do
    note = Note.create!(user: @student, content: "Student note", is_global: true)
    sign_in_as(@admin)

    patch note_path(note), params: { note: { content: "Hacked by admin" } }
    assert_redirected_to admin_root_path

    assert_no_difference("Note.count") do
      delete note_path(note)
    end
    assert_redirected_to admin_root_path
  end

  test "super admin can delete any note" do
    note = Note.create!(user: @student, content: "Note moderated by teacher", is_global: true)
    sign_in_as(@super_admin)

    assert_difference("Note.count", -1) do
      delete note_path(note)
    end
    assert_redirected_to notes_path
  end

  test "non-owner cannot delete note" do
    note = Note.create!(user: @student, content: "Protected from deletion", is_global: true)
    sign_in_as(@other_student)

    assert_no_difference("Note.count") do
      delete note_path(note)
    end
    assert_redirected_to notes_path
    assert_equal "Only the owner can delete this note.", flash[:alert]
  end

  test "can delete note via turbo stream" do
    note = Note.create!(user: @student, content: "Note to delete via turbo", is_global: true)
    sign_in_as(@student)

    assert_difference("Note.count", -1) do
      delete note_path(note), as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, %(target="note_#{note.id}")
  end
end
