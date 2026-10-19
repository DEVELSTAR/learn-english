class NotesController < ApplicationController
  allow_unauthenticated_access only: %i[index]
  before_action :set_note, only: %i[edit update destroy]

  def index
    @notes = Note.includes(:user).recent
    @new_note = Note.new
  end

  def create
    @note = current_user.notes.build(note_params)

    if @note.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to notes_path, notice: "Note shared successfully!" }
      end
    else
      @notes = Note.includes(:user).recent
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("new_note_form_wrapper", partial: "notes/form", locals: { note: @note })
        end
        format.html { redirect_to notes_path, alert: @note.errors.full_messages.to_sentence }
      end
    end
  end

  # Anyone authenticated can edit any note
  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "note_#{@note.id}",
          partial: "notes/edit_form",
          locals: { note: @note }
        )
      end
      format.html { render :edit }
    end
  end

  # Anyone authenticated can update any note
  def update
    if @note.update(note_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("note_#{@note.id}", partial: "notes/note", locals: { note: @note }),
            turbo_stream.update("flash_messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to notes_path, notice: "Note updated!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "note_#{@note.id}",
            partial: "notes/edit_form",
            locals: { note: @note }
          )
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # Only the owner (or admin) can delete a note
  def destroy
    unless @note.user == current_user || current_user.admin?
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to notes_path, alert: "Only the owner can delete this note." }
      end
      return
    end

    @note_id = @note.id
    @note.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notes_path, notice: "Note deleted." }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
