class TopicsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    @topics = Lesson.published.topics.ordered_topics

    if params[:query].present?
      q = "%#{params[:query].strip.downcase}%"
      @topics = @topics.where("LOWER(title) LIKE ? OR LOWER(COALESCE(introduction, '')) LIKE ?", q, q)
    end
  end

  def show
    @lesson = Lesson.published.topics.find_by!(slug: params[:id])
    @previous_lesson = @lesson.previous_lesson
    @next_lesson = @lesson.next_lesson
    @comments = @lesson.lesson_comments.includes(:user).chronological

    if authenticated?
      @completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
      @chat_messages = @lesson.lesson_chat_messages.where(user: current_user).order(:created_at)
    else
      @chat_messages = []
    end

    render "lessons/show"
  end
end

