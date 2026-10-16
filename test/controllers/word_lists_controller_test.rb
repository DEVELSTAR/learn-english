require "test_helper"

class WordListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student_one = users(:student_one)
    @student_two = users(:student_two)
    @list_one = word_lists(:student_one_my_words)
    @list_two = word_lists(:student_two_my_words)
    @admin_list = WordList.create!(user: @admin, name: "IELTS High-Frequency", is_default: false)
  end

  test "guest is redirected to sign in" do
    get word_lists_path
    assert_redirected_to new_session_path
  end

  test "student can view their own lists" do
    sign_in_as(@student_one)
    get word_lists_path
    assert_response :success
    assert_select "span", text: @list_one.name
  end

  test "student can see admin-created shared lists" do
    sign_in_as(@student_one)
    get word_lists_path
    assert_response :success
    assert_select "span", text: @admin_list.name
  end

  test "student cannot delete an admin-created shared list" do
    sign_in_as(@student_one)
    assert_no_difference("WordList.count") do
      delete word_list_path(@admin_list)
    end
    assert_redirected_to word_lists_path
    follow_redirect!
    assert_select "div", text: /not authorized/
  end

  test "student can create custom list" do
    sign_in_as(@student_one)
    assert_difference("@student_one.word_lists.count", 1) do
      post word_lists_path, params: { word_list: { name: "Phrasal Verbs" } }
    end
    assert_redirected_to word_lists_path(id: WordList.last.id)
  end

  test "student cannot delete default list" do
    sign_in_as(@student_one)
    assert_no_difference("WordList.count") do
      delete word_list_path(@list_one)
    end
    assert_redirected_to word_lists_path
    follow_redirect!
    assert_select "div", text: /Default lists cannot be deleted/
  end

  test "student can create custom list with initial words" do
    sign_in_as(@student_one)
    words = "afford: have enough money\npersuade - convince someone"

    assert_difference("@student_one.word_lists.count", 1) do
      assert_difference("WordEntry.count", 2) do
        post word_lists_path, params: { word_list: { name: "Phrasal Verbs with Words", initial_words: words } }
      end
    end

    created_list = WordList.find_by(name: "Phrasal Verbs with Words")
    assert_not_nil created_list
    assert_equal 2, created_list.word_entries.count
    assert_redirected_to word_lists_path(id: created_list.id)
    follow_redirect!
    assert_includes response.body, "with 2 words"
  end
end
