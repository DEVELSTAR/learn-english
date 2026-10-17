class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    @today_lesson = Lesson.published.for_today.first
    @latest_lesson = Lesson.latest_published
    @recent_lessons = Lesson.published.daily_classes.by_date_desc.limit(5)
    @featured_topics = Lesson.published.topics.ordered_topics.limit(3)

    if authenticated?
      @default_list = current_user.word_lists.find_by(is_default: true) || current_user.word_lists.first
      @word_lists = current_user.word_lists.default_first
      @words_due_revision = current_user.word_entries.due_for_revision.limit(6)
      @recent_words = current_user.word_entries.recent.limit(6)
      @completed_count = current_user.lesson_completions.where(completed: true).count
    end
  end
end
