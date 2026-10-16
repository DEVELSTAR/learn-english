require "test_helper"

class LessonChatMessageTest < ActiveSupport::TestCase
  setup do
    @student = users(:student_one)
    @lesson = lessons(:compare_lesson)
  end

  test "valid user message saves successfully" do
    msg = LessonChatMessage.new(
      lesson: @lesson,
      user: @student,
      role: :user,
      content: "Can I say 'I compared my car with his car'?"
    )
    assert msg.valid?
    assert msg.save
    assert msg.user?
  end

  test "valid assistant message saves successfully" do
    msg = LessonChatMessage.new(
      lesson: @lesson,
      user: @student,
      role: :assistant,
      content: "Yes, absolutely! 'Compare with' is the exact natural collocation."
    )
    assert msg.valid?
    assert msg.save
    assert msg.assistant?
  end

  test "requires content, role, lesson, and user" do
    msg = LessonChatMessage.new
    assert_not msg.valid?
    assert_includes msg.errors[:content], "can't be blank"
    assert_includes msg.errors[:role], "can't be blank"
    assert_includes msg.errors[:lesson], "must exist"
    assert_includes msg.errors[:user], "must exist"
  end

  test "scopes order messages correctly" do
    m1 = @lesson.lesson_chat_messages.create!(user: @student, role: :user, content: "First")
    m2 = @lesson.lesson_chat_messages.create!(user: @student, role: :assistant, content: "Second")

    assert_equal [m1, m2], @lesson.lesson_chat_messages.where(user: @student).chronological
  end
end

