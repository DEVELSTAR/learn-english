require "test_helper"

module Lessons
  class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @student = users(:student_one)
      @lesson = lessons(:compare_lesson)
    end

    test "guest cannot send chat message and is redirected" do
      assert_no_difference("LessonChatMessage.count") do
        post lesson_chat_messages_path(@lesson), params: { content: "Can you help me?" }
      end
      assert_redirected_to new_session_path
    end

    test "student can send chat message via turbo stream and receive AI response" do
      sign_in_as(@student)

      GeminiTutorService.any_instance.stubs(:ask).returns("Great question! Here is your answer in Hinglish.") if GeminiTutorService.respond_to?(:stubs)

      # Using stub on GeminiTutorService#ask
      GeminiTutorService.class_eval do
        alias_method :orig_ask, :ask
        def ask(msg)
          "Great question! Aap 'compare with' use karein."
        end
      end

      begin
        assert_difference("LessonChatMessage.count", 2) do
          post lesson_chat_messages_path(@lesson),
               params: { content: "How do I compare two cars?" },
               as: :turbo_stream
        end

        assert_response :success
        assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type

        # Verify messages in DB
        user_msg = LessonChatMessage.where(lesson: @lesson, user: @student, role: :user).last
        assistant_msg = LessonChatMessage.where(lesson: @lesson, user: @student, role: :assistant).last

        assert_equal "How do I compare two cars?", user_msg.content
        assert_equal "Great question! Aap 'compare with' use karein.", assistant_msg.content

        # Turbo stream updates
        assert_includes response.body, %(action="append" target="chat_messages_list")
        assert_includes response.body, "How do I compare two cars?"
        assert_includes response.body, "Great question! Aap 'compare with' use karein."
      ensure
        GeminiTutorService.class_eval do
          alias_method :ask, :orig_ask
          remove_method :orig_ask
        end
      end
    end

    test "blank message is ignored" do
      sign_in_as(@student)

      assert_no_difference("LessonChatMessage.count") do
        post lesson_chat_messages_path(@lesson), params: { content: "   " }, as: :turbo_stream
      end

      assert_response :success
    end

    test "student can send chat message via HTML redirect" do
      sign_in_as(@student)

      GeminiTutorService.class_eval do
        alias_method :orig_ask, :ask
        def ask(msg)
          "HTML response answer."
        end
      end

      begin
        assert_difference("LessonChatMessage.count", 2) do
          post lesson_chat_messages_path(@lesson), params: { content: "Another question" }
        end

        assert_redirected_to lesson_path(@lesson, anchor: "ai-tutor")
      ensure
        GeminiTutorService.class_eval do
          alias_method :ask, :orig_ask
          remove_method :orig_ask
        end
      end
    end
  end
end
