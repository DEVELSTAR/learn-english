class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[index]
  before_action :redirect_admin_to_dashboard, only: :index

  def index
    @today_lesson = Lesson.published.for_today.first
    @latest_lesson = Lesson.latest_published
    @recent_lessons = Lesson.published.daily_classes.by_date_desc.limit(5)
    @featured_topics = Lesson.published.topics.ordered_topics.limit(3)

    if authenticated?
      @recent_notes = Note.includes(:user).recent.limit(5)
      @completed_count = current_user.lesson_completions.where(completed: true).count
    end
  end

  private

  def redirect_admin_to_dashboard
    redirect_to admin_root_path if authenticated? && current_user.admin?
  end
end
