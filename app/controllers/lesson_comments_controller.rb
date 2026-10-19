class LessonCommentsController < ApplicationController
  include LessonCommentsHelper

  before_action :set_lesson
  before_action :set_comment, only: :destroy

  def create
    @comment = @lesson.lesson_comments.build(comment_params)
    @comment.user = current_user

    if @comment.parent_id.present?
      parent = @lesson.lesson_comments.find_by(id: @comment.parent_id)
      if parent
        # Keep replies flat under the root comment for a cleaner threaded experience
        @comment.parent = parent.root? ? parent : parent.parent
      else
        @comment.parent_id = nil
      end
    end

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to lesson_target_path(@lesson, anchor: "lesson_comment_#{@comment.id}"),
                      notice: "Comment posted!"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          target_dom_id = @comment.parent_id.present? ? "reply_form_lesson_comment_#{@comment.parent_id}" : "new_lesson_comment_form_wrapper"
          render turbo_stream: turbo_stream.replace(
            target_dom_id,
            partial: "lesson_comments/form",
            locals: { lesson: @lesson, comment: @comment, parent_id: @comment.parent_id }
          )
        end
        format.html do
          redirect_to lesson_target_path(@lesson, anchor: "comments-section"),
                      alert: @comment.errors.full_messages.to_sentence
        end
      end
    end
  end

  def destroy
    unless @comment.user == current_user || current_user.admin?
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to lesson_target_path(@lesson, anchor: "comments-section"), alert: "You are not authorized to delete this comment." }
      end
      return
    end

    @comment_id = @comment.id
    @parent = @comment.parent
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to lesson_target_path(@lesson, anchor: "comments-section"), notice: "Comment deleted." }
    end
  end

  private

  def set_lesson
    slug_or_id = params[:lesson_id] || params[:topic_id]
    @lesson = Lesson.find_by(slug: slug_or_id) || Lesson.find_by!(id: slug_or_id)
  end

  def set_comment
    @comment = @lesson.lesson_comments.find(params[:id])
  end

  def comment_params
    params.require(:lesson_comment).permit(:content, :parent_id)
  end
end

