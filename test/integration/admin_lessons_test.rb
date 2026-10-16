require "test_helper"

class AdminLessonsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @lesson = lessons(:compare_lesson)
  end

  test "admin can destroy a lesson using its slug" do
    sign_in_as(@admin)

    assert_difference("Lesson.count", -1) do
      delete "/admin/lessons/#{@lesson.slug}"
    end

    assert_response :redirect
    assert_redirected_to "/admin/lessons"
    follow_redirect!
    assert_includes response.body, "Lesson was successfully destroyed"
  end

  test "admin can destroy a lesson using its numeric id" do
    sign_in_as(@admin)
    new_lesson = Lesson.create!(title: "Another Lesson", lesson_date: Date.current, status: :draft, author: @admin)

    assert_difference("Lesson.count", -1) do
      delete "/admin/lessons/#{new_lesson.id}"
    end

    assert_response :redirect
    assert_redirected_to "/admin/lessons"
  end
end
