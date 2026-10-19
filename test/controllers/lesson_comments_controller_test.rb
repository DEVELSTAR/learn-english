require "test_helper"

class LessonCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student_one)
    @other_student = users(:student_two)
    @admin = users(:admin)
    @daily_class = lessons(:compare_lesson)
    @topic = lessons(:topic_lesson)
  end

  test "unauthenticated user can poll comments via json" do
    get lesson_comments_path(@daily_class), headers: { "Accept" => "application/json" }
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("comments")
    assert data.key?("total_count")
  end

  test "polling with after_id returns only newer comments" do
    c1 = LessonComment.create!(lesson: @daily_class, user: @student, content: "First message")
    c2 = LessonComment.create!(lesson: @daily_class, user: @other_student, content: "Second message")

    get lesson_comments_path(@daily_class, after_id: c1.id), headers: { "Accept" => "application/json" }
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal 1, data["comments"].length
    assert_equal c2.id, data["comments"].first["id"]
  end

  test "unauthenticated user cannot post comment" do
    assert_no_difference("LessonComment.count") do
      post lesson_comments_path(@daily_class), params: {
        lesson_comment: { content: "Unauthenticated comment" }
      }
    end
    assert_redirected_to new_session_path
  end

  test "student can post root comment on a daily class" do
    sign_in_as(@student)

    assert_difference("@daily_class.lesson_comments.count", 1) do
      post lesson_comments_path(@daily_class), params: {
        lesson_comment: { content: "Great class! I loved this concept." }
      }
    end

    comment = @daily_class.lesson_comments.last
    assert_equal @student, comment.user
    assert_nil comment.parent_id
    assert_redirected_to lesson_path(@daily_class, anchor: "lesson_comment_#{comment.id}")
  end

  test "student can post root comment on a topic" do
    sign_in_as(@student)

    assert_difference("@topic.lesson_comments.count", 1) do
      post topic_comments_path(@topic), params: {
        lesson_comment: { content: "Great foundational topic discussion." }
      }
    end

    comment = @topic.lesson_comments.last
    assert_equal @student, comment.user
    assert_nil comment.parent_id
    assert_redirected_to topic_path(@topic, anchor: "lesson_comment_#{comment.id}")
  end

  test "can post comment via turbo stream" do
    sign_in_as(@student)

    assert_difference("LessonComment.count", 1) do
      post lesson_comments_path(@daily_class),
           params: { lesson_comment: { content: "Turbo stream comment test" } },
           as: :turbo_stream
    end

    assert_response :success
    assert_includes response.body, "turbo-stream"
    assert_includes response.body, "Turbo stream comment test"
  end

  test "can post reply to a root comment" do
    sign_in_as(@admin)
    root_comment = LessonComment.create!(lesson: @daily_class, user: @student, content: "What does this mean?")

    assert_difference("@daily_class.lesson_comments.count", 1) do
      post lesson_comments_path(@daily_class), params: {
        lesson_comment: { content: "Let me explain it in Hindi...", parent_id: root_comment.id }
      }
    end

    reply = @daily_class.lesson_comments.last
    assert_equal root_comment, reply.parent
    assert_equal @admin, reply.user
    assert_redirected_to lesson_path(@daily_class, anchor: "lesson_comment_#{reply.id}")
  end

  test "author can delete their own comment" do
    comment = LessonComment.create!(lesson: @daily_class, user: @student, content: "My own comment to delete")
    sign_in_as(@student)

    assert_difference("LessonComment.count", -1) do
      delete lesson_comment_path(@daily_class, comment)
    end

    assert_redirected_to lesson_path(@daily_class, anchor: "comments-section")
  end

  test "admin can delete any user's comment" do
    comment = LessonComment.create!(lesson: @daily_class, user: @student, content: "Student comment moderated by teacher")
    sign_in_as(@admin)

    assert_difference("LessonComment.count", -1) do
      delete lesson_comment_path(@daily_class, comment)
    end

    assert_redirected_to lesson_path(@daily_class, anchor: "comments-section")
  end

  test "user cannot delete another user's comment" do
    comment = LessonComment.create!(lesson: @daily_class, user: @student, content: "Student one's comment")
    sign_in_as(@other_student)

    assert_no_difference("LessonComment.count") do
      delete lesson_comment_path(@daily_class, comment)
    end

    assert_redirected_to lesson_path(@daily_class, anchor: "comments-section")
    assert_equal "You are not authorized to delete this comment.", flash[:alert]
  end

  test "can delete comment via turbo stream" do
    comment = LessonComment.create!(lesson: @daily_class, user: @student, content: "To be removed via turbo")
    sign_in_as(@student)

    assert_difference("LessonComment.count", -1) do
      delete lesson_comment_path(@daily_class, comment), as: :turbo_stream
    end

    assert_response :success
    assert_includes response.body, %(target="lesson_comment_#{comment.id}")
  end
end

