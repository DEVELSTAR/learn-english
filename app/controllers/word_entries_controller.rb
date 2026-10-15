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
      redirect_back_or_to_lists notice: "'#{@word_entry.term}' added to #{@word_list.name}."
    else
      redirect_back_or_to_lists alert: @word_entry.errors.full_messages.join(", ")
    end
  end

  def update
    if @word_entry.update(entry_params)
      redirect_back_or_to_lists notice: "Word updated successfully."
    else
      redirect_back_or_to_lists alert: @word_entry.errors.full_messages.join(", ")
    end
  end

  def update_status
    if params[:status].present? && WordEntry.statuses.key?(params[:status])
      @word_entry.update!(status: params[:status])
      @word_entry.mark_reviewed!
      redirect_back_or_to_lists notice: "Status of '#{@word_entry.term}' changed to #{@word_entry.status.humanize}."
    else
      redirect_back_or_to_lists alert: "Invalid status."
    end
  end

  def toggle_revision
    @word_entry.toggle!(:needs_revision)
    @word_entry.mark_reviewed!
    msg = @word_entry.needs_revision? ? "'#{@word_entry.term}' marked for revision." : "Removed from revision."
    redirect_back_or_to_lists notice: msg
  end

  def destroy
    term = @word_entry.term
    @word_entry.destroy!
    redirect_back_or_to_lists notice: "'#{term}' removed."
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
