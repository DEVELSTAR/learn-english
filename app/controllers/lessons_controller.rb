class LessonsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_lesson, only: %i[show toggle_completion toggle_revision]

  def index
    @lessons = Lesson.published.by_date_desc

    if params[:query].present?
      q = "%#{params[:query].strip.downcase}%"
      @lessons = @lessons.where("LOWER(title) LIKE ? OR LOWER(COALESCE(introduction, '')) LIKE ? OR LOWER(COALESCE(topic, '')) LIKE ?", q, q, q)
    end

    if params[:topic].present?
      @lessons = @lessons.where(topic: params[:topic])
    end

    @topics = Lesson.published.where.not(topic: [nil, ""]).distinct.pluck(:topic).sort
  end

  def show
    # Only allow published lessons for students unless teacher is viewing
    if @lesson.draft? && !admin?
      redirect_to lessons_path, alert: "This lesson has not been published yet."
      return
    end

    @previous_lesson = @lesson.previous_lesson
    @next_lesson = @lesson.next_lesson
    
    if authenticated?
      @completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
      @user_word_lists = current_user.word_lists.default_first
      @saved_word_terms = current_user.word_entries.pluck(:term).map(&:downcase)
    end
  end

  def toggle_completion
    completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
    completion.completed = !completion.completed
    completion.completed_at = completion.completed? ? Time.current : nil
    completion.save!

    redirect_to lesson_path(@lesson), notice: completion.completed? ? "Lesson marked as completed! Keep it up." : "Lesson marked as incomplete."
  end

  def toggle_revision
    completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
    completion.needs_revision = !completion.needs_revision
    completion.save!

    redirect_to lesson_path(@lesson), notice: completion.needs_revision? ? "Lesson added to your revision list." : "Lesson removed from revision."
  end

  private

  def set_lesson
    @lesson = Lesson.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    # Fallback to integer id if needed
    @lesson = Lesson.find(params[:id])
  end
end

