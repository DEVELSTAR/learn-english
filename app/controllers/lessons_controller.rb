class LessonsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_lesson, only: %i[show toggle_completion toggle_revision clear_chat]

  def index
    @lessons = Lesson.published.daily_classes.by_date_desc

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
    @comments = @lesson.lesson_comments.includes(:user, replies: :user).root_comments.recent_first
    
    if authenticated?
      @completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
      @user_word_lists = current_user.word_lists.default_first
      @saved_word_terms = current_user.word_entries.pluck(:term).map(&:downcase)
      @chat_messages = @lesson.lesson_chat_messages.where(user: current_user).chronological
    end
  end

  def toggle_completion
    @completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
    @completion.completed = !@completion.completed
    @completion.completed_at = @completion.completed? ? Time.current : nil
    @completion.save!

    notice_msg = @completion.completed? ? "Lesson marked as completed! Keep it up." : "Lesson marked as incomplete."

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice_msg
        render turbo_stream: [
          turbo_stream.replace("lesson_student_actions", partial: "lessons/student_actions", locals: { lesson: @lesson, completion: @completion }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to lesson_path(@lesson), notice: notice_msg }
    end
  end

  def toggle_revision
    @completion = current_user.lesson_completions.find_or_initialize_by(lesson: @lesson)
    @completion.needs_revision = !@completion.needs_revision
    @completion.save!

    notice_msg = @completion.needs_revision? ? "Lesson added to your revision list." : "Lesson removed from revision."

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice_msg
        render turbo_stream: [
          turbo_stream.replace("lesson_student_actions", partial: "lessons/student_actions", locals: { lesson: @lesson, completion: @completion }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to lesson_path(@lesson), notice: notice_msg }
    end
  end

  def clear_chat
    @lesson.lesson_chat_messages.where(user: current_user).destroy_all
    notice_msg = "AI chat history cleared for this lesson."

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice_msg
        render turbo_stream: [
          turbo_stream.update("chat_messages_list", partial: "lessons/chat_empty_state"),
          turbo_stream.replace("chat_input_container", partial: "lessons/chat_input", locals: { lesson: @lesson }),
          turbo_stream.replace("clear_chat_container", partial: "lessons/clear_chat_button", locals: { lesson: @lesson, has_messages: false }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to (@lesson.topic? ? topic_path(@lesson, anchor: "ai-tutor") : lesson_path(@lesson, anchor: "ai-tutor")), notice: notice_msg }
    end
  end

  private

  def set_lesson
    @lesson = Lesson.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    # Fallback to integer id if needed
    @lesson = Lesson.find(params[:id])
  end
end

