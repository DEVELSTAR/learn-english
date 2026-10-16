require "test_helper"

module WordLists
  class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @student = users(:student_one)
      @other_student = users(:student_two)
      @word_list = word_lists(:student_one_my_words)
      @other_list = word_lists(:student_two_my_words)
    end

    test "guest cannot send chat message and is redirected" do
      assert_no_difference("WordListChatMessage.count") do
        post word_list_chat_messages_path(@word_list), params: { content: "Check my sentence" }
      end
      assert_redirected_to new_session_path
    end

    test "student can send chat message via turbo stream and receive AI response" do
      sign_in_as(@student)

      GeminiTutorService.class_eval do
        alias_method :orig_ask, :ask
        def ask(msg)
          "Shabash! Aapka sentence kaafi achha hai."
        end
      end

      begin
        assert_difference("WordListChatMessage.count", 2) do
          post word_list_chat_messages_path(@word_list),
               params: { content: "Can you check my sentence: I can afford this?" },
               as: :turbo_stream
        end

        assert_response :success
        assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type

        user_msg = WordListChatMessage.where(word_list: @word_list, user: @student, role: :user).last
        assistant_msg = WordListChatMessage.where(word_list: @word_list, user: @student, role: :assistant).last

        assert_equal "Can you check my sentence: I can afford this?", user_msg.content
        assert_equal "Shabash! Aapka sentence kaafi achha hai.", assistant_msg.content

        # Turbo stream updates
        assert_includes response.body, %(action="append" target="word_list_chat_messages_list")
        assert_includes response.body, "Can you check my sentence: I can afford this?"
        assert_includes response.body, "Shabash! Aapka sentence kaafi achha hai."
        assert_includes response.body, "data-controller=\"speaker\""
      ensure
        GeminiTutorService.class_eval do
          alias_method :ask, :orig_ask
          remove_method :orig_ask
        end
      end
    end

    test "blank message is ignored" do
      sign_in_as(@student)

      assert_no_difference("WordListChatMessage.count") do
        post word_list_chat_messages_path(@word_list), params: { content: "   " }, as: :turbo_stream
      end

      assert_response :success
    end

    test "student cannot chat on another student private list" do
      sign_in_as(@student)

      post word_list_chat_messages_path(@other_list), params: { content: "Hello" }
      assert_response :not_found
    end

    test "student can clear word list chat history via turbo stream" do
      sign_in_as(@student)
      assert @word_list.word_list_chat_messages.where(user: @student).exists?

      delete clear_chat_word_list_path(@word_list), as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
      assert_includes response.body, %(action="update" target="word_list_chat_messages_list")
      assert_equal 0, @word_list.word_list_chat_messages.where(user: @student).count
    end
  end
end
