class LessonCommentsController < ApplicationController
  include LessonCommentsHelper

  allow_unauthenticated_access only: %i[index]

  before_action :set_lesson
  before_action :set_comment, only: :destroy

  def index
    after_id = params[:after_id].to_i
    scope = @lesson.lesson_comments.includes(:user).chronological
    @new_comments = after_id.positive? ? scope.where("id > ?", after_id) : scope

    respond_to do |format|
      format.json do
        render json: {
          total_count: @lesson.lesson_comments.count,
          comments: @new_comments.map do |comment|
            {
              id: comment.id,
              html: render_to_string(
                partial: "lesson_comments/chat_bubble",
                locals: { comment: comment },
                formats: [ :html ]
              )
            }
          end
        }
      end
      format.html do
        redirect_to lesson_target_path(@lesson, anchor: "comments-section")
      end
    end
  end

  def create
    @comment = @lesson.lesson_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to lesson_target_path(@lesson, anchor: "lesson_comment_#{@comment.id}"),
                      notice: "Message sent!"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @comment.errors.full_messages.to_sentence
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash")
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
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to lesson_target_path(@lesson, anchor: "comments-section"), notice: "Message deleted." }
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
