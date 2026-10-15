require "test_helper"

class RevisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student_one = users(:student_one)
    @entry_one = word_entries(:entry_one)
  end

  test "guest is redirected to login" do
    get revision_path
    assert_redirected_to new_session_path
  end

  test "student can view revision page and filtered entries" do
    sign_in_as(@student_one)
    get revision_path
    assert_response :success
    assert_select "h1", text: "Vocabulary Revision"
    assert_select "span", text: @entry_one.term
  end

  test "student can mark entry as reviewed" do
    sign_in_as(@student_one)
    post revision_reviewed_path(@entry_one)
    assert_redirected_to revision_path
    assert_not_nil @entry_one.reload.last_reviewed_at
  end

  test "student can mark entry as mastered" do
    sign_in_as(@student_one)
    post revision_reviewed_path(@entry_one, mastered: "true")
    assert_redirected_to revision_path
    @entry_one.reload
    assert @entry_one.learned?
    assert_not @entry_one.needs_revision?
  end
end
