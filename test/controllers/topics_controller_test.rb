require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student_one)
    @topic = Lesson.create!(
      title: "Get Started with English",
      lesson_type: :topic,
      position: 1,
      lesson_date: Date.current,
      status: :published,
      author: users(:admin)
    )
  end

  test "guest can view topics index" do
    get topics_path
    assert_response :success
    assert_includes response.body, "Foundational Topics"
    assert_includes response.body, "Get Started with English"
  end

  test "authenticated student can view a topic show page with AI tutor and actions" do
    sign_in_as(@student)
    get topic_path(@topic)

    assert_response :success
    assert_includes response.body, "Get Started with English"
    assert_includes response.body, "Ask Akib Sir"
  end

  test "can search topics by query" do
    get topics_path(query: "Started")
    assert_response :success
    assert_includes response.body, "Get Started with English"
  end
end
