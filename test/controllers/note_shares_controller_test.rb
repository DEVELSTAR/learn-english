require "test_helper"

class NoteSharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:student_one)
    @invited_student = users(:student_two)
    @note = Note.create!(user: @owner, content: "Collaborative lesson notes", is_global: false)
  end

  test "note owner can invite students" do
    sign_in_as(@owner)

    assert_difference("NoteShare.count", 1) do
      post note_shares_path, params: {
        note_id: @note.id,
        user_ids: [@invited_student.id],
        can_edit: "1"
      }
    end

    share = NoteShare.last
    assert_equal @note, share.note
    assert_equal @invited_student, share.user
    assert_equal true, share.can_edit?
    assert_equal "pending", share.status
    assert_redirected_to notes_path
  end

  test "non-owner cannot invite students" do
    sign_in_as(@invited_student)

    assert_no_difference("NoteShare.count") do
      post note_shares_path, params: {
        note_id: @note.id,
        user_ids: [@invited_student.id],
        can_edit: "0"
      }
    end

    assert_redirected_to notes_path
    assert_equal "Only the note creator can invite students.", flash[:alert]
  end

  test "invited student can accept invitation" do
    share = NoteShare.create!(note: @note, user: @invited_student, can_edit: true, status: :pending)
    sign_in_as(@invited_student)

    post accept_note_share_path(share)
    assert_redirected_to notes_path
    assert_equal "Invitation accepted!", flash[:notice]

    share.reload
    assert_equal "accepted", share.status
  end

  test "invited student can decline invitation" do
    share = NoteShare.create!(note: @note, user: @invited_student, can_edit: false, status: :pending)
    sign_in_as(@invited_student)

    post decline_note_share_path(share)
    assert_redirected_to notes_path
    assert_equal "Invitation declined.", flash[:notice]

    share.reload
    assert_equal "declined", share.status
  end

  test "owner can remove a note share" do
    share = NoteShare.create!(note: @note, user: @invited_student, can_edit: true, status: :accepted)
    sign_in_as(@owner)

    assert_difference("NoteShare.count", -1) do
      delete note_share_path(share)
    end
    assert_redirected_to notes_path
  end
end

