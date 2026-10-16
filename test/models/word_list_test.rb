require "test_helper"

class WordListTest < ActiveSupport::TestCase
  setup do
    @student = users(:student_one)
    @list = word_lists(:student_one_my_words)
  end

  test "add_words_from_text parses colon, hyphen, pipe, and plain formats" do
    text = <<~TXT
      afford: have enough money to buy
      persuade - convince someone to do something
      accomplish | complete successfully
      grateful
    TXT

    added = @list.add_words_from_text(text, user: @student)
    assert_equal 4, added

    entry1 = @list.word_entries.find_by(term: "afford")
    assert_not_nil entry1
    assert_equal "have enough money to buy", entry1.personal_note

    entry2 = @list.word_entries.find_by(term: "persuade")
    assert_not_nil entry2
    assert_equal "convince someone to do something", entry2.personal_note

    entry3 = @list.word_entries.find_by(term: "accomplish")
    assert_not_nil entry3
    assert_equal "complete successfully", entry3.personal_note

    entry4 = @list.word_entries.find_by(term: "grateful")
    assert_not_nil entry4
    assert_equal "", entry4.personal_note.to_s
  end

  test "add_words_from_text ignores blank lines and whitespace" do
    text = "   \n\n   \n"
    added = @list.add_words_from_text(text, user: @student)
    assert_equal 0, added
  end
end

