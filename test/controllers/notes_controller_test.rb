require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student_one)
    @other_student = users(:student_two)
    @admin = users(:admin)
  end

  test "unauthenticated user can view notes index" do
    get notes_path
    assert_response :success
    assert_includes response.body, "Notes"
  end

  test "unauthenticated user cannot create note" do
    assert_no_difference("Note.count") do
      post notes_path, params: {
        note: { title: "Daily Sentences", content: "Unauthenticated note content." }
      }
    end
    assert_redirected_to new_session_path
  end

  test "authenticated student can create note" do
    sign_in_as(@student)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          title: "Useful Airport Sentences",
          content: "1. Where is the check-in counter?\n2. Could you please show me your boarding pass?\n3. I have one carry-on bag."
        }
      }
    end

    note = Note.last
    assert_equal @student, note.user
    assert_equal "Useful Airport Sentences", note.title
    assert_includes note.content, "Where is the check-in counter?"
    assert_redirected_to notes_path
  end

  test "can create note via turbo stream" do
    sign_in_as(@student)

    assert_difference("Note.count", 1) do
      post notes_path,
           params: { note: { title: "Turbo Stream Title", content: "Sentence 1\nSentence 2\nSentence 3" } },
           as: :turbo_stream
    end

    assert_response :success
    assert_includes response.body, "turbo-stream"
    assert_includes response.body, "Turbo Stream Title"
  end

  test "author can edit their note" do
    note = Note.create!(user: @student, title: "Original Title", content: "Original content")
    sign_in_as(@student)

    get edit_note_path(note), as: :turbo_stream
    assert_response :success
    assert_includes response.body, "Original Title"

    patch note_path(note), params: {
      note: { title: "Updated Title", content: "Updated content by author" }
    }
    assert_redirected_to notes_path

    note.reload
    assert_equal "Updated Title", note.title
    assert_equal "Updated content by author", note.content
  end

  test "can update note via turbo stream" do
    note = Note.create!(user: @student, title: "Initial Title", content: "Before turbo update")
    sign_in_as(@student)

    patch note_path(note),
          params: { note: { title: "Edited Title", content: "After turbo update" } },
          as: :turbo_stream
    assert_response :success
    assert_includes response.body, "After turbo update"

    note.reload
    assert_equal "Edited Title", note.title
    assert_equal "After turbo update", note.content
  end

  test "anyone authenticated can edit another student note" do
    note = Note.create!(user: @student, title: "Collaborative English Phrases", content: "Sentence added by student one.")
    sign_in_as(@other_student)

    # other student edits student one's note
    patch note_path(note), params: {
      note: { title: "Collaborative English Phrases (Updated)", content: "Sentence 1\nSentence 2 added by student two." }
    }
    assert_redirected_to notes_path
    assert_equal "Note updated!", flash[:notice]

    note.reload
    assert_equal "Collaborative English Phrases (Updated)", note.title
    assert_includes note.content, "Sentence 2 added by student two."
  end

  test "admin can edit any note" do
    note = Note.create!(user: @student, title: "Draft Sentences", content: "Grammar mistake here.")
    sign_in_as(@admin)

    patch note_path(note), params: {
      note: { title: "Corrected Sentences", content: "Correct grammar updated by admin." }
    }
    assert_redirected_to notes_path

    note.reload
    assert_equal "Corrected Sentences", note.title
    assert_equal "Correct grammar updated by admin.", note.content
  end

  test "author can delete their note" do
    note = Note.create!(user: @student, title: "To Delete", content: "Note to delete")
    sign_in_as(@student)

    assert_difference("Note.count", -1) do
      delete note_path(note)
    end
    assert_redirected_to notes_path
  end

  test "admin can delete any note" do
    note = Note.create!(user: @student, title: "To Delete Admin", content: "Note moderated by teacher")
    sign_in_as(@admin)

    assert_difference("Note.count", -1) do
      delete note_path(note)
    end
    assert_redirected_to notes_path
  end

  test "student cannot delete another student note" do
    note = Note.create!(user: @student, title: "Student One Note", content: "Protected from deletion")
    sign_in_as(@other_student)

    assert_no_difference("Note.count") do
      delete note_path(note)
    end
    assert_redirected_to notes_path
    assert_equal "Only the owner can delete this note.", flash[:alert]
  end

  test "can delete note via turbo stream" do
    note = Note.create!(user: @student, title: "Turbo Delete", content: "Note to delete via turbo")
    sign_in_as(@student)

    assert_difference("Note.count", -1) do
      delete note_path(note), as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, %(target="note_#{note.id}")
  end
end
