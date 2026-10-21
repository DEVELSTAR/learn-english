class NoteSharesController < ApplicationController
  before_action :require_authentication
  before_action :restrict_admin_access!

  def create
    @note = Note.find(params[:note_id])
    unless @note.can_delete?(current_user)
      redirect_to notes_path, alert: "Only the note creator can invite students." and return
    end

    user_ids = Array(params[:user_ids] || params[:user_id]).reject(&:blank?)
    can_edit = ActiveRecord::Type::Boolean.new.cast(params[:can_edit]) || false

    created_count = 0
    user_ids.each do |uid|
      student = User.students.find_by(id: uid)
      next unless student && student != @note.user

      share = @note.note_shares.find_or_initialize_by(user: student)
      share.can_edit = can_edit
      share.status = :pending if share.new_record? || share.declined?
      created_count += 1 if share.save
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Invitations sent to #{created_count} #{'student'.pluralize(created_count)}!"
        render turbo_stream: [
          turbo_stream.replace("note_#{@note.id}", partial: "notes/note", locals: { note: @note.reload }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to notes_path, notice: "Invitations sent!" }
    end
  end

  def accept
    @share = current_user.received_note_shares.find(params[:id])
    @share.update!(status: :accepted)
    @note = @share.note

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Invitation accepted! You can now view this note."
        render turbo_stream: [
          turbo_stream.remove("note_invitation_#{@share.id}"),
          turbo_stream.update("pending_invitations_count", current_user.received_note_shares.pending.count.to_s),
          turbo_stream.prepend("notes_list", partial: "notes/note", locals: { note: @note }),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to notes_path, notice: "Invitation accepted!" }
    end
  end

  def decline
    @share = current_user.received_note_shares.find(params[:id])
    @share.update!(status: :declined)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Invitation declined."
        render turbo_stream: [
          turbo_stream.remove("note_invitation_#{@share.id}"),
          turbo_stream.update("pending_invitations_count", current_user.received_note_shares.pending.count.to_s),
          turbo_stream.update("flash_messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to notes_path, notice: "Invitation declined." }
    end
  end

  def destroy
    @share = NoteShare.find(params[:id])
    unless @share.note.can_delete?(current_user) || @share.user == current_user
      head :forbidden and return
    end

    @note = @share.note
    @share.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("note_#{@note.id}", partial: "notes/note", locals: { note: @note.reload })
      end
      format.html { redirect_to notes_path, notice: "Share removed." }
    end
  end

  private

  def restrict_admin_access!
    if current_user.regular_admin?
      redirect_to admin_root_path, alert: "Administrators cannot manage note sharing."
    end
  end
end

