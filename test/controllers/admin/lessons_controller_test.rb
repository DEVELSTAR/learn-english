require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @student = users(:student_one)
      @lesson = lessons(:compare_lesson)
    end

    test "student is blocked from admin studio" do
      sign_in_as(@student)
      get admin_lessons_path
      assert_redirected_to root_path
      follow_redirect!
      assert_select "div", text: /Access denied/
    end

    test "student is blocked from editing a lesson" do
      sign_in_as(@student)
      get edit_admin_lesson_path(@lesson)
      assert_redirected_to root_path
    end

    test "teacher can access admin studio index" do
      sign_in_as(@admin)
      get admin_lessons_path
      assert_response :success
      assert_select "#page_title", text: "Lessons"
    end

    test "teacher can view new lesson form" do
      sign_in_as(@admin)
      get new_admin_lesson_path
      assert_response :success
      assert_select "input#lesson_lesson_date[type='date'][value='#{Date.current}']"
      assert_select "input#lesson_lesson_date[style*='width: 180px']"
      assert_select "trix-editor#lesson_content"
    end

    test "teacher can create a new lesson" do
      sign_in_as(@admin)
      assert_difference("Lesson.count", 1) do
        post admin_lessons_path, params: {
          lesson: {
            title: "New Test Lesson",
            lesson_date: Date.current,
            status: "draft"
          }
        }
      end

      new_lesson = Lesson.find_by(title: "New Test Lesson")
      assert_not_nil new_lesson
      assert_equal @admin.id, new_lesson.author_id
      assert_redirected_to admin_lessons_path
    end

    test "teacher can publish and unpublish a lesson via get and patch" do
      sign_in_as(@admin)
      draft = lessons(:draft_lesson)
      assert draft.draft?

      # Test GET request (browser link click)
      get publish_admin_lesson_path(draft)
      assert draft.reload.published?
      assert_redirected_to admin_lessons_path

      get unpublish_admin_lesson_path(draft)
      assert draft.reload.draft?
      assert_redirected_to admin_lessons_path

      # Test PATCH request
      patch publish_admin_lesson_path(draft)
      assert draft.reload.published?

      patch unpublish_admin_lesson_path(draft)
      assert draft.reload.draft?
    end

    test "show page displays publish action item for draft lessons" do
      sign_in_as(@admin)
      draft = lessons(:draft_lesson)
      get admin_lesson_path(draft)
      assert_response :success
      assert_select "a", text: "Publish Lesson"

      published = lessons(:compare_lesson)
      get admin_lesson_path(published)
      assert_response :success
      assert_select "a", text: "Unpublish Lesson"
    end

    test "show page displays full rich text content and attached image" do
      sign_in_as(@admin)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("fake-image-bytes"),
        filename: "admin_test_image.png",
        content_type: "image/png"
      )
      @lesson.content.body = "<div><p>Special Admin Note</p><action-text-attachment sgid=\"#{blob.attachable_sgid}\"></action-text-attachment></div>"
      @lesson.save!

      get admin_lesson_path(@lesson)
      assert_response :success
      assert_select "div.trix-content", text: /Special Admin Note/
      assert_select "img[src*='/rails/active_storage/blobs/proxy/']"
    end

    test "teacher can create a lesson with rich text content" do
      sign_in_as(@admin)
      assert_difference("Lesson.count", 1) do
        post admin_lessons_path, params: {
          lesson: {
            title: "Mastering Collocations",
            lesson_date: Date.current,
            status: "published",
            content: "<div><h2>Key Points</h2><ul><li>Take for granted</li><li>Compare with</li></ul></div>"
          }
        }
      end

      new_lesson = Lesson.find_by(title: "Mastering Collocations")
      assert_not_nil new_lesson
      assert_equal "published", new_lesson.status
      assert_includes new_lesson.content.to_s, "Key Points"
      assert_redirected_to admin_lessons_path
    end

    test "teacher can update lesson title and rich text content" do
      sign_in_as(@admin)
      patch admin_lesson_path(@lesson), params: {
        lesson: {
          title: "Updated Title for Compare",
          content: "<p>Updated rich text with bullets and images</p>"
        }
      }
      assert_redirected_to admin_lessons_path
      @lesson.reload
      assert_equal "Updated Title for Compare", @lesson.title
      assert_includes @lesson.content.to_s, "Updated rich text"
    end

    test "teacher can delete a lesson" do
      sign_in_as(@admin)
      assert_difference("Lesson.count", -1) do
        delete admin_lesson_path(@lesson)
      end
      assert_redirected_to admin_lessons_path
    end
  end
end

