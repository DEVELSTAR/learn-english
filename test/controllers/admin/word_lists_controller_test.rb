require "test_helper"

module Admin
  class WordListsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @student = users(:student_one)
      @shared_list = word_lists(:admin_shared_list)
    end

    test "student is blocked from shared word lists admin" do
      sign_in_as(@student)
      get admin_shared_word_lists_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "div", text: /Access denied/
    end

    test "admin can view shared word lists index" do
      sign_in_as(@admin)
      get admin_shared_word_lists_path
      assert_response :success
      assert_select "#page_title", text: "Shared Word Lists"
      assert_select "td", text: @shared_list.name
    end

    test "admin can view new shared list form" do
      sign_in_as(@admin)
      get new_admin_shared_word_list_path
      assert_response :success
      assert_select "#page_title", text: "New Shared Word List"
    end

    test "admin can create a shared list" do
      sign_in_as(@admin)
      assert_difference("WordList.count", 1) do
        post admin_shared_word_lists_path, params: {
          word_list: {
            name: "Master Business English"
          }
        }
      end

      new_list = WordList.find_by(name: "Master Business English")
      assert_not_nil new_list
      assert_equal @admin.id, new_list.user_id
      assert_redirected_to admin_shared_word_list_path(new_list)
    end

    test "admin can view shared list details and add entry" do
      sign_in_as(@admin)
      get admin_shared_word_list_path(@shared_list)
      assert_response :success
      assert_select "#page_title", text: @shared_list.name

      assert_difference("@shared_list.word_entries.count", 1) do
        post add_entry_admin_shared_word_list_path(@shared_list), params: {
          word_entry: {
            term: "Synergy",
            personal_note: "Working together effectively"
          }
        }
      end

      assert_redirected_to admin_shared_word_list_path(@shared_list)
      follow_redirect!
      assert_select "strong", text: "Synergy"
    end

    test "admin can remove entry from shared list" do
      sign_in_as(@admin)
      entry = @shared_list.word_entries.create!(
        user: @admin,
        term: "Deprecated Word",
        personal_note: "To be removed"
      )

      assert_difference("@shared_list.word_entries.count", -1) do
        delete remove_entry_admin_shared_word_list_path(@shared_list, entry_id: entry.id)
      end

      assert_redirected_to admin_shared_word_list_path(@shared_list)
    end

    test "admin can edit and update shared list name" do
      sign_in_as(@admin)
      get edit_admin_shared_word_list_path(@shared_list)
      assert_response :success
      assert_select "#page_title", text: "Edit Shared Word List"

      patch admin_shared_word_list_path(@shared_list), params: {
        word_list: {
          name: "Updated Office Communication"
        }
      }

      assert_redirected_to admin_shared_word_lists_path
      @shared_list.reload
      assert_equal "Updated Office Communication", @shared_list.name
    end

    test "admin can create a shared list with initial words in bulk" do
      sign_in_as(@admin)
      assert_difference("WordList.count", 1) do
        assert_difference("WordEntry.count", 2) do
          post admin_shared_word_lists_path, params: {
            word_list: {
              name: "Top 20 Travel Words",
              initial_words: "itinerary: travel plan\nboarding pass: ticket for plane"
            }
          }
        end
      end

      new_list = WordList.find_by(name: "Top 20 Travel Words")
      assert_not_nil new_list
      assert_equal 2, new_list.word_entries.count
      assert_redirected_to admin_shared_word_list_path(new_list)
      follow_redirect!
      assert_includes response.body, "created with 2 words"
    end

    test "admin can add bulk words to existing shared list" do
      sign_in_as(@admin)
      assert_difference("@shared_list.word_entries.count", 2) do
        post add_entry_admin_shared_word_list_path(@shared_list), params: {
          word_entry: {
            bulk_words: "collaborate: work together\nschedule: set meeting time"
          }
        }
      end

      assert_redirected_to admin_shared_word_list_path(@shared_list)
      follow_redirect!
      assert_includes response.body, "2 words added"
    end
  end
end
