module Lessons
  class ChatMessagesController < ApplicationController
    before_action :set_lesson

    def create
      content = params[:content].to_s.strip

      if content.blank?
        respond_to do |format|
          format.turbo_stream { head :ok }
          format.html { redirect_to lesson_path(@lesson, anchor: "ai-tutor") }
        end
        return
      end

      # 1. Save user's question / sentence
      @user_message = @lesson.lesson_chat_messages.create!(
        user: current_user,
        role: :user,
        content: content
      )

      # 2. Get AI response from Gemini
      ai_response = GeminiTutorService.new(@lesson, current_user).ask(content)

      # 3. Save assistant's answer
      @assistant_message = @lesson.lesson_chat_messages.create!(
        user: current_user,
        role: :assistant,
        content: ai_response
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to lesson_path(@lesson, anchor: "ai-tutor") }
      end
    end

    private

    def set_lesson
      @lesson = Lesson.find_by!(slug: params[:lesson_id])
    end
  end
end
