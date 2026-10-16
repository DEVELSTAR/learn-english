class WordEntriesController < ApplicationController
  before_action :set_word_entry, only: %i[update destroy toggle_revision update_status]

  def create
    list_id = params[:word_entry][:word_list_id].presence
    # Check if target list is user's own list, or admin list
    target_list = current_user.word_lists.find_by(id: list_id)

    if target_list.nil?
      # If student tried to save into an admin list or didn't supply one, save to student's default list
      target_list = current_user.word_lists.find_by(is_default: true) || current_user.word_lists.first
    end

    @word_list = target_list
    @word_entry = current_user.word_entries.build(entry_params)
    @word_entry.word_list = @word_list

    if @word_entry.save
      notice_msg = "'#{@word_entry.term}' added to #{@word_list.name}."
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice_msg
          saved_terms = current_user.word_entries.pluck(:term).map(&:downcase)
          streams = [
            turbo_stream.update("flash_messages", partial: "shared/flash")
          ]

          # If saved from lesson page
          if @word_entry.lesson.present?
            streams << turbo_stream.replace("lesson_word_saver", partial: "lessons/word_saver", locals: { lesson: @word_entry.lesson })
          end

          # If on word lists page
          streams << turbo_stream.remove("word_entries_empty_state")
          streams << turbo_stream.prepend("word_entries_list", partial: "word_entries/word_entry", locals: { entry: @word_entry, active_list: @word_list, saved_word_terms: saved_terms })
          streams << turbo_stream.replace("quick_add_word_form", partial: "word_lists/quick_add_form", locals: { active_list: @word_list })
          streams << turbo_stream.update("active_list_count", "#{@word_list.word_entries.count} #{'entry'.pluralize(@word_list.word_entries.count)} showing")

          render turbo_stream: streams
        end
        format.html { redirect_back_or_to_lists notice: notice_msg }
      end
    else
      alert_msg = @word_entry.errors.full_messages.join(", ")
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = alert_msg
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash")
        end
        format.html { redirect_back_or_to_lists alert: alert_msg }
      end
    end
  end

  def update
    if @word_entry.update(entry_params)
      notice_msg = "Word updated successfully."
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice_msg
          saved_terms = current_user.word_entries.pluck(:term).map(&:downcase)
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@word_entry), partial: "word_entries/word_entry", locals: { entry: @word_entry, active_list: @word_entry.word_list, saved_word_terms: saved_terms }),
            turbo_stream.update("flash_messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_back_or_to_lists notice: notice_msg }
      end
    else
      alert_msg = @word_entry.errors.full_messages.join(", ")
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = alert_msg
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash")
        end
        format.html { redirect_back_or_to_lists alert: alert_msg }
      end
    end
  end

  def update_status
    if params[:status].present? && WordEntry.statuses.key?(params[:status])
      @word_entry.update!(status: params[:status])
      @word_entry.mark_reviewed!
      notice_msg = "Status of '#{@word_entry.term}' changed to #{@word_entry.status.humanize}."

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice_msg
          saved_terms = current_user.word_entries.pluck(:term).map(&:downcase)
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@word_entry), partial: "word_entries/word_entry", locals: { entry: @word_entry, active_list: @word_entry.word_list, saved_word_terms: saved_terms }),
            turbo_stream.update("flash_messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_back_or_to_lists notice: notice_msg }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Invalid status."
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash")
        end
        format.html { redirect_back_or_to_lists alert: "Invalid status." }
      end
    end
  end

  def toggle_revision
    @word_entry.toggle!(:needs_revision)
    @word_entry.mark_reviewed!
    notice_msg = @word_entry.needs_revision? ? "'#{@word_entry.term}' marked for revision." : "Removed from revision."

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice_msg
        saved_terms = current_user.word_entries.pluck(:term).map(&:downcase)
        render turbo_stream: [
          turbo_stream.replace(helpers.dom_id(@word_entry), partial: "word_entries/word_entry", locals: { entry: @word_entry, active_list: @word_entry.word_list, saved_word_terms: saved_terms }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_back_or_to_lists notice: notice_msg }
    end
  end

  def destroy
    term = @word_entry.term
    word_list = @word_entry.word_list
    entry_dom_id = helpers.dom_id(@word_entry)
    @word_entry.destroy!
    notice_msg = "'#{term}' removed."

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice_msg
        render turbo_stream: [
          turbo_stream.remove(entry_dom_id),
          turbo_stream.update("active_list_count", "#{word_list.word_entries.count} #{'entry'.pluralize(word_list.word_entries.count)} showing"),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_back_or_to_lists notice: notice_msg }
    end
  end

  private

  def set_word_entry
    # Scoped strictly to current_user to prevent any cross-account access
    @word_entry = current_user.word_entries.find(params[:id])
  end

  def entry_params
    params.require(:word_entry).permit(:term, :personal_note, :word_list_id, :lesson_id, :status, :needs_revision)
  end

  def redirect_back_or_to_lists(flash_hash)
    if params[:return_to].present?
      redirect_to params[:return_to], flash_hash.merge(status: :see_other)
    else
      redirect_to word_lists_path(id: @word_entry&.word_list_id || @word_list&.id), flash_hash.merge(status: :see_other)
    end
  end
end
