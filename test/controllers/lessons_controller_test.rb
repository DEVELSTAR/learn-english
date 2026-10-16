require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_lesson = lessons(:compare_lesson)
    @draft_lesson = lessons(:draft_lesson)
    @student = users(:student_one)
    @admin = users(:admin)
  end

  test "guest can view published lessons index" do
    get lessons_path
    assert_response :success
    assert_select "h2", text: /Mastering 'Compare'/
    assert_includes response.body, "data-controller=\"speaker\""
  end

  test "guest can search published lessons" do
    get lessons_path, params: { query: "Compare" }
    assert_response :success
    assert_select "h2", text: /Mastering 'Compare'/
  end

  test "student can view published lesson show page" do
    sign_in_as(@student)
    get lesson_path(@published_lesson)
    assert_response :success
    assert_select "h1", text: @published_lesson.title
    assert_includes response.body, "Listen to this Class"
    assert_includes response.body, "data-controller=\"speaker\""
  end

  test "student cannot view draft lesson" do
    sign_in_as(@student)
    get lesson_path(@draft_lesson)
    assert_redirected_to lessons_path
    follow_redirect!
    assert_select "div", text: /not been published yet/
  end

  test "teacher can view draft lesson" do
    sign_in_as(@admin)
    get lesson_path(@draft_lesson)
    assert_response :success
    assert_select "h1", text: @draft_lesson.title
  end

  test "student can toggle lesson completion" do
    sign_in_as(@student)
    assert_difference("LessonCompletion.count", 1) do
      post toggle_completion_lesson_path(@published_lesson)
    end
    assert_redirected_to lesson_path(@published_lesson)
    assert @published_lesson.completed_by?(@student)

    # Toggle off
    assert_no_difference("LessonCompletion.count") do
      post toggle_completion_lesson_path(@published_lesson)
    end
    assert_not @published_lesson.completed_by?(@student)
  end

  test "student can toggle lesson revision" do
    sign_in_as(@student)
    post toggle_revision_lesson_path(@published_lesson)
    assert @published_lesson.needs_revision_for?(@student)
  end

  test "student can view lesson with attached image" do
    sign_in_as(@student)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("fake-image-bytes"),
      filename: "student_test_image.png",
      content_type: "image/png"
    )
    @published_lesson.content.body = "<div><p>Look at this chart:</p><action-text-attachment sgid=\"#{blob.attachable_sgid}\"></action-text-attachment></div>"
    @published_lesson.save!

    get lesson_path(@published_lesson)
    assert_response :success
    assert_select "img[src*='/rails/active_storage/blobs/proxy/']"
  end

  test "student can clear their AI chat history for a lesson" do
    sign_in_as(@student)
    @published_lesson.lesson_chat_messages.create!(user: @student, role: :user, content: "My question")
    @published_lesson.lesson_chat_messages.create!(user: @student, role: :assistant, content: "My answer")

    assert_difference("LessonChatMessage.count", -2) do
      delete clear_chat_lesson_path(@published_lesson)
    end

    assert_redirected_to lesson_path(@published_lesson, anchor: "ai-tutor")
  end

  test "student can toggle lesson completion via turbo stream" do
    sign_in_as(@student)
    post toggle_completion_lesson_path(@published_lesson), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_includes response.body, %(target="lesson_student_actions")
    assert_includes response.body, "Completed"
  end

  test "student can toggle lesson revision via turbo stream" do
    sign_in_as(@student)
    post toggle_revision_lesson_path(@published_lesson), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_includes response.body, %(target="lesson_student_actions")
    assert_includes response.body, "Marked for Revision"
  end

  test "student can clear chat via turbo stream" do
    sign_in_as(@student)
    @published_lesson.lesson_chat_messages.create!(user: @student, role: :user, content: "My question")

    delete clear_chat_lesson_path(@published_lesson), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_includes response.body, %(target="chat_messages_list")
    assert_includes response.body, "chat_empty_state"
  end
end

