module WordLists
  class ChatMessagesController < ApplicationController
    before_action :set_word_list

    def create
      content = params[:content].to_s.strip

      if content.blank?
        respond_to do |format|
          format.turbo_stream { head :ok }
          format.html { redirect_to word_lists_path(id: @word_list.id, anchor: "word-list-ai-tutor") }
        end
        return
      end

      # 1. Save student's question or practice sentence
      @user_message = @word_list.word_list_chat_messages.create!(
        user: current_user,
        role: :user,
        content: content
      )

      # 2. Query Gemini AI Tutor (provides active word list vocabulary context)
      ai_response = GeminiTutorService.new(@word_list, current_user).ask(content)

      # 3. Save assistant's answer
      @assistant_message = @word_list.word_list_chat_messages.create!(
        user: current_user,
        role: :assistant,
        content: ai_response
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to word_lists_path(id: @word_list.id, anchor: "word-list-ai-tutor") }
      end
    end

    private

    def set_word_list
      @word_list = WordList.visible_to(current_user).find(params[:word_list_id])
    end
  end
end

