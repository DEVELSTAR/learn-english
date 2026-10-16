require "test_helper"

class AdminTopicsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "admin can view topics in active admin" do
    sign_in_as(@admin)
    get "/admin/topics"
    assert_response :success
    assert_includes response.body, "Topics"
  end

  test "admin can create and delete a topic" do
    sign_in_as(@admin)

    assert_difference("Lesson.topics.count", 1) do
      post "/admin/topics", params: {
        lesson: {
          title: "Must Know Slang Words",
          position: 3,
          status: "published",
          lesson_type: "topic"
        }
      }
    end

    assert_response :redirect
    new_topic = Lesson.topics.find_by!(title: "Must Know Slang Words")
    assert_equal 3, new_topic.position
    assert new_topic.topic?

    assert_difference("Lesson.topics.count", -1) do
      delete "/admin/topics/#{new_topic.slug}"
    end

    assert_response :redirect
    assert_redirected_to "/admin/topics"
  end
end
