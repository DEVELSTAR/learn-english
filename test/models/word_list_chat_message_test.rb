require "test_helper"

class WordListChatMessageTest < ActiveSupport::TestCase
  setup do
    @student = users(:student_one)
    @word_list = word_lists(:student_one_my_words)
  end

  test "validates role inclusion and content presence" do
    msg = WordListChatMessage.new(word_list: @word_list, user: @student)
    assert_not msg.valid?
    assert_includes msg.errors[:role], "can't be blank"
    assert_includes msg.errors[:content], "can't be blank"

    msg.role = "user"
    msg.content = "Can I afford this?"
    assert msg.valid?
  end

  test "supports user and assistant roles" do
    user_msg = @word_list.word_list_chat_messages.create!(user: @student, role: :user, content: "Hello")
    assert user_msg.user?
    assert_not user_msg.assistant?

    ai_msg = @word_list.word_list_chat_messages.create!(user: @student, role: :assistant, content: "Hello there!")
    assert ai_msg.assistant?
    assert_not ai_msg.user?
  end
end
