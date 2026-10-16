class RevisionsController < ApplicationController
  before_action :require_authentication

  def index
    @filter = params[:filter].presence || "due"

    @revision_lessons = current_user.lesson_completions.where(needs_revision: true).includes(:lesson).map(&:lesson)

    base_entries = current_user.word_entries.recent

    @entries = case @filter
               when "flagged"
                 base_entries.needs_revision
               when "in_progress"
                 base_entries.in_progress
               when "learned"
                 base_entries.where(status: :learned)
               else # "due"
                 current_user.word_entries.due_for_revision
               end

    if params[:query].present?
      @entries = @entries.search(params[:query])
    end

    @total_due = current_user.word_entries.due_for_revision.count
    @total_flagged = current_user.word_entries.needs_revision.count
    @total_learned = current_user.word_entries.where(status: :learned).count
  end

  def reviewed
    entry = current_user.word_entries.find(params[:id])
    
    if params[:mastered] == "true"
      entry.update!(status: :learned, needs_revision: false, last_reviewed_at: Time.current)
      msg = "Shabash! '#{entry.term}' marked as Learned and removed from revision queue."
    else
      entry.mark_reviewed!
      msg = "'#{entry.term}' reviewed."
    end

    total_due = current_user.word_entries.due_for_revision.count
    total_flagged = current_user.word_entries.needs_revision.count
    total_learned = current_user.word_entries.where(status: :learned).count

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = msg
        render turbo_stream: [
          turbo_stream.remove(helpers.dom_id(entry)),
          turbo_stream.replace("revision_stats", partial: "revisions/stats", locals: { total_due: total_due, total_flagged: total_flagged, total_learned: total_learned }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html do
        flash[:notice] = msg
        redirect_to revision_path(filter: params[:filter])
      end
    end
  end
end

