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
end

