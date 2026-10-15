require "test_helper"

class WordEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student_one = users(:student_one)
    @student_two = users(:student_two)
    @list_one = word_lists(:student_one_my_words)
    @entry_one = word_entries(:entry_one)
    @entry_two = word_entries(:entry_private_to_two)
  end

  test "student can quick add a word" do
    sign_in_as(@student_one)
    assert_difference("@student_one.word_entries.count", 1) do
      post word_entries_path, params: {
        word_entry: {
          term: "Collocation",
          word_list_id: @list_one.id,
          personal_note: "Words that naturally go together"
        }
      }
    end
    assert_redirected_to word_lists_path(id: @list_one.id)
  end

  test "duplicate word in same list is prevented with warning" do
    sign_in_as(@student_one)
    assert_no_difference("WordEntry.count") do
      post word_entries_path, params: {
        word_entry: {
          term: @entry_one.term, # "Compare" already exists in student_one_my_words
          word_list_id: @list_one.id
        }
      }
    end
    assert_redirected_to word_lists_path(id: @list_one.id)
    follow_redirect!
    assert_select "div", text: /already in this list/
  end

  test "student cannot modify another student's word entry" do
    sign_in_as(@student_one)
    patch word_entry_path(@entry_two), params: { word_entry: { term: "Hacked" } }
    assert_response :not_found
  end

  test "student cannot delete another student's word entry" do
    sign_in_as(@student_one)
    delete word_entry_path(@entry_two)
    assert_response :not_found
  end

  test "student can toggle revision on their own entry" do
    sign_in_as(@student_one)
    post toggle_revision_word_entry_path(@entry_one)
    assert_not @entry_one.reload.needs_revision?

    post toggle_revision_word_entry_path(@entry_one)
    assert @entry_one.reload.needs_revision?
  end

  test "student can update status of their word entry" do
    sign_in_as(@student_one)
    patch update_status_word_entry_path(@entry_one, status: "learned")
    assert @entry_one.reload.learned?
  end
end
