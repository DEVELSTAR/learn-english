require "net/http"
require "json"

class GeminiTutorService
  DEFAULT_MODELS = [ "gemini-flash-latest", "gemini-flash-lite-latest" ].freeze

  attr_reader :context_record, :user

  def initialize(context_record, user)
    @context_record = context_record
    @user = user
  end

  def lesson
    @context_record if @context_record.is_a?(Lesson)
  end

  def word_list
    @context_record if @context_record.is_a?(WordList)
  end

  def ask(user_message)
    api_key = ENV["GEMINI_API_KEY"].presence || (Rails.application.credentials.gemini_api_key.presence unless Rails.env.test?)

    if api_key.blank?
      return fallback_response(user_message)
    end

    call_gemini_api(api_key, user_message)
  rescue StandardError => e
    Rails.logger.error("[GeminiTutorService] Error: #{e.class} - #{e.message}")
    "Maaf kijiye, abhi AI response connect karne mein thodi problem aayi (#{e.message}). Please thodi der baad dobara koshish karein!"
  end

  private

  def models
    [ ENV["GEMINI_MODEL"].presence, *DEFAULT_MODELS ].compact.uniq
  end

  def call_gemini_api(api_key, user_message)
    last_error_message = nil

    models.each do |model_name|
      endpoint_url = "https://generativelanguage.googleapis.com/v1beta/models/#{model_name}:generateContent?key=#{api_key}"
      uri = URI(endpoint_url)

      system_prompt = build_system_prompt
      contents = build_contents(user_message)

      payload = {
        system_instruction: {
          parts: [ { text: system_prompt } ]
        },
        contents: contents,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 2048
        }
      }

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = payload.to_json

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.request(req)
      end

      if res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body)
        candidate = data.dig("candidates", 0, "content", "parts", 0, "text")
        return candidate.presence || "Main aapka question samajh nahi paaya, kya aap dobara pooch sakte hain?"
      else
        Rails.logger.warn("[GeminiTutorService] Model '#{model_name}' returned #{res.code}: #{res.body.to_s.truncate(200)}")
        error_data = JSON.parse(res.body) rescue {}
        last_error_message = error_data.dig("error", "message") || res.message
      end
    end

    "AI Tutor se connect nahi ho paaya: #{last_error_message}. Please check your GEMINI_API_KEY or try again shortly."
  end

  def build_system_prompt
    if word_list.present?
      words = word_list.word_entries.limit(30).map { |e| "- #{e.term}#{": #{e.personal_note}" if e.personal_note.present?}" }.join("\n")
      context_info = <<~CTX
        CURRENT VOCABULARY LIST CONTEXT:
        - List Name: "#{word_list.name}"
        - Saved Words in this List:
        #{words.presence || '(No words saved in this list yet)'}
      CTX
    elsif lesson.present?
      lesson_summary = lesson.content&.to_plain_text.to_s.truncate(1500)
      type_label = lesson.topic? ? "Topic" : "Daily Class"
      context_info = <<~CTX
        CURRENT #{type_label.upcase} CONTEXT:
        - Title: "#{lesson.title}"
        - Type: #{type_label}
        - Date: #{lesson.lesson_date&.strftime('%B %d, %Y')}
        - Content / Key Concepts:
        #{lesson_summary.presence || '(No lesson text provided)'}
      CTX
    else
      context_info = "GENERAL ENGLISH VOCABULARY PRACTICE"
    end

    <<~PROMPT
      You are a warm, highly encouraging, and patient personal English Tutor named 'Akib Sir' on the 'Learn English' web app.
      You specialize in helping Hindi-speaking students become fluent and confident in everyday, spoken, and professional English.

      #{context_info}

      STUDENT PROFILE:
      - Name: #{user.name}
      - The student is learning English and prefers simple, natural conversational Hinglish (Hindi written in Roman English script + clear English sentences).

      TEACHING & RESPONSE GUIDELINES:
      1. Explanations:
         - Keep explanations clear, friendly, and relatable.
         - Mix conversational Hinglish with English (e.g., "Jab aap kisi cheez ki value pehle se maan lete hain...").
         - Use short bullet points and bold formatting for key English vocabulary.
      2. Sentence Correction ("Correct me if I'm wrong"):
         - If the student writes a sentence and asks for feedback or tries to practice:
           a. Acknowledge what was good (positive reinforcement).
           b. Gently point out any grammatical or collocation errors.
           c. Provide the natural, native alternative in bold.
           d. Explain the 'why' in simple Hinglish so they remember the concept.
      3. Practice Encouragement:
         - Keep answers concise (under 150-200 words) so the student isn't overwhelmed.
         - End with a quick follow-up question or micro-challenge asking them to make a sentence using one of the words.
    PROMPT
  end

  def build_contents(current_user_message)
    if lesson.present?
      history = lesson.lesson_chat_messages.where(user: user).recent_for_context(4)
    elsif word_list.present?
      history = word_list.word_list_chat_messages.where(user: user).recent_for_context(4)
    else
      history = []
    end

    contents = []

    history.each do |msg|
      gemini_role = msg.assistant? ? "model" : "user"
      # Gemini requires alternating roles; only push if valid
      if contents.empty? || contents.last[:role] != gemini_role
        contents << {
          role: gemini_role,
          parts: [ { text: msg.content } ]
        }
      end
    end

    # Ensure the history starts with a user message if present
    contents.shift if contents.first && contents.first[:role] != "user"

    # Add the current message
    contents << {
      role: "user",
      parts: [ { text: current_user_message } ]
    }

    contents
  end

  def fallback_response(user_message)
    title_context = lesson&.title || word_list&.name || "English Practice"
    <<~MSG
      Namaste #{user.name}! 🙏 Main aapka **AI English Tutor** hoon.

      Aapka question tha: *"#{user_message.truncate(100)}"*

      Live Gemini 1.5 Flash AI responses ko activate karne ke liye, please apna free **GEMINI_API_KEY** environment variable mein add karein:
      - Render Dashboard > Web Service > Environment > Add `GEMINI_API_KEY`
      - *(Aap 30 seconds mein free key le sakte hain: [aistudio.google.com](https://aistudio.google.com/))*

      **Quick Tip for '#{title_context}':**
      Is context ke keywords se ek sentence banayein aur daily conversation mein use karein!
    MSG
  end
end
