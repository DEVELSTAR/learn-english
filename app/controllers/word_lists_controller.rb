class WordListsController < ApplicationController
  before_action :set_word_list, only: %i[show destroy]

  def index
    @my_lists = current_user.word_lists.default_first
    @teacher_lists = WordList.created_by_admin.where.not(user_id: current_user.id).order(:name)
    @all_visible_lists = (@my_lists + @teacher_lists).uniq

    @active_list = if params[:id].present?
                     WordList.visible_to(current_user).find_by(id: params[:id])
                   else
                     @my_lists.find(&:is_default?) || @my_lists.first || @all_visible_lists.first
                   end

    if @active_list
      @entries = @active_list.word_entries.recent
      if params[:query].present?
        @entries = @entries.search(params[:query])
      end
      if params[:status].present?
        @entries = @entries.where(status: params[:status])
      end
    else
      @entries = WordEntry.none
    end

    @saved_word_terms = current_user.word_entries.pluck(:term).map(&:downcase)
  end

  def show
    redirect_to word_lists_path(id: @word_list.id, query: params[:query], status: params[:status])
  end

  def create
    @word_list = current_user.word_lists.build(list_params)
    @word_list.is_default = false

    if @word_list.save
      redirect_to word_lists_path(id: @word_list.id), notice: "List '#{@word_list.name}' created#{current_user.admin? ? ' and shared with all students' : ''}."
    else
      redirect_to word_lists_path, alert: @word_list.errors.full_messages.join(", ")
    end
  end

  def destroy
    if @word_list.is_default?
      redirect_to word_lists_path, alert: "Default lists cannot be deleted."
    elsif !@word_list.can_manage?(current_user)
      redirect_to word_lists_path, alert: "You are not authorized to delete this list."
    else
      name = @word_list.name
      @word_list.destroy!
      redirect_to word_lists_path, status: :see_other, notice: "List '#{name}' was deleted."
    end
  end

  private

  def set_word_list
    @word_list = WordList.visible_to(current_user).find(params[:id])
  end

  def list_params
    params.require(:word_list).permit(:name)
  end
end
