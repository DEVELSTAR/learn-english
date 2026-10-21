class NotesController < ApplicationController
  allow_unauthenticated_access only: %i[index]
  before_action :restrict_admin_access!
  before_action :set_note, only: %i[edit update destroy]

  def index
    @filter = params[:filter].presence || "all"

    base_scope = Note.visible_to(current_user).includes(:user, :lesson)

    @notes = case @filter
             when "mine"
               authenticated? ? current_user.notes.includes(:user, :lesson).recent : base_scope.none
             when "shared"
               authenticated? ? Note.where(id: current_user.received_note_shares.accepted.select(:note_id)).includes(:user, :lesson).recent : base_scope.none
             when "lesson"
               base_scope.where.not(lesson_id: nil).recent
             when "general"
               base_scope.where(lesson_id: nil).recent
             else
               base_scope.recent
             end

    if params[:lesson_id].present?
      @notes = @notes.where(lesson_id: params[:lesson_id])
    end

    if authenticated?
      @pending_shares = current_user.received_note_shares.pending.includes(note: :user)
      @available_students = User.students.where.not(id: current_user.id).order(:name)
    else
      @pending_shares = []
      @available_students = []
    end

    @new_note = Note.new(lesson_id: params[:lesson_id], is_global: true)
  end

  def create
    @note = current_user.notes.build(note_params)

    # By default, notes are global unless user explicitly unchecked it or selected specific students
    if params[:sharing_mode] == "shared"
      @note.is_global = false
    elsif params[:note][:is_global].present?
      @note.is_global = ActiveRecord::Type::Boolean.new.cast(params[:note][:is_global])
    end

    if @note.save
      # If sharing with specific students was chosen
      if params[:invite_user_ids].present?
        user_ids = Array(params[:invite_user_ids]).reject(&:blank?)
        can_edit = ActiveRecord::Type::Boolean.new.cast(params[:invite_can_edit]) || false

        user_ids.each do |uid|
          student = User.students.find_by(id: uid)
          next unless student && student != current_user

          @note.note_shares.create(user: student, can_edit: can_edit, status: :pending)
        end
      end

      respond_to do |format|
        format.turbo_stream
        format.html do
          if @note.lesson
            redirect_to lesson_target_path(@note.lesson, anchor: "lesson_notes_section"), notice: "Note shared successfully!"
          else
            redirect_to notes_path, notice: "Note shared successfully!"
          end
        end
      end
    else
      @notes = Note.visible_to(current_user).includes(:user, :lesson).recent
      @pending_shares = authenticated? ? current_user.received_note_shares.pending.includes(note: :user) : []
      @available_students = authenticated? ? User.students.where.not(id: current_user.id).order(:name) : []

      respond_to do |format|
        format.turbo_stream do
          target_form = @note.lesson_id.present? ? "new_lesson_note_form_wrapper" : "new_note_form_wrapper"
          render turbo_stream: turbo_stream.replace(target_form, partial: "notes/form", locals: { note: @note, lesson: @note.lesson })
        end
        format.html { redirect_to notes_path, alert: @note.errors.full_messages.to_sentence }
      end
    end
  end

  def edit
    unless @note.can_edit?(current_user)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to notes_path, alert: "You are not authorized to edit this note." }
      end
      return
    end

    @available_students = User.students.where.not(id: current_user.id).order(:name)

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

  def update
    unless @note.can_edit?(current_user)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to notes_path, alert: "You are not authorized to edit this note." }
      end
      return
    end

    if @note.update(note_params)
      # If owner is updating sharing settings
      if @note.can_delete?(current_user)
        if params[:sharing_mode] == "shared"
          @note.update_column(:is_global, false)
        elsif params[:sharing_mode] == "global"
          @note.update_column(:is_global, true)
        end

        if params[:invite_user_ids].present?
          user_ids = Array(params[:invite_user_ids]).reject(&:blank?)
          can_edit = ActiveRecord::Type::Boolean.new.cast(params[:invite_can_edit]) || false
          user_ids.each do |uid|
            student = User.students.find_by(id: uid)
            next unless student && student != current_user

            share = @note.note_shares.find_or_initialize_by(user: student)
            share.can_edit = can_edit
            share.status = :pending if share.new_record?
            share.save
          end
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Note updated!"
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

  def destroy
    unless @note.can_delete?(current_user)
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
    params.require(:note).permit(:content, :lesson_id, :is_global)
  end

  def lesson_target_path(lesson, options = {})
    lesson.topic? ? topic_path(lesson, options) : lesson_path(lesson, options)
  end

  def restrict_admin_access!
    if authenticated? && current_user.regular_admin?
      redirect_to admin_root_path, alert: "Administrators cannot access or manage community notes."
    end
  end
end
