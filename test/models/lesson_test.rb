require "test_helper"

class LessonTest < ActiveSupport::TestCase
  test "generates slug automatically from title on create" do
    lesson = Lesson.create!(
      title: "How to use 'Nuance' accurately",
      lesson_date: Date.current,
      status: :published
    )
    assert_equal "how-to-use-nuance-accurately", lesson.slug
  end

  test "validates uniqueness of slug" do
    lesson1 = Lesson.create!(title: "Unique Title", lesson_date: Date.current)
    lesson2 = Lesson.new(title: "Another", slug: lesson1.slug, lesson_date: Date.current)
    assert_not lesson2.valid?
    assert_includes lesson2.errors[:slug], "has already been taken"
  end

  test "previous and next lesson navigation" do
    teacher = users(:admin)
    l1 = Lesson.create!(title: "Lesson Future 1", lesson_date: Date.current + 10.days, status: :published, author: teacher)
    l2 = Lesson.create!(title: "Lesson Future 2", lesson_date: Date.current + 11.days, status: :published, author: teacher)
    l3 = Lesson.create!(title: "Lesson Future 3", lesson_date: Date.current + 12.days, status: :published, author: teacher)

    assert_equal l1, l2.previous_lesson
    assert_equal l3, l2.next_lesson
    assert_equal l2, l3.previous_lesson
    assert_nil l3.next_lesson
  end
end
