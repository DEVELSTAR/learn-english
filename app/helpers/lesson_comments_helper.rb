module LessonCommentsHelper
  def lesson_comment_path_for(lesson, comment = nil)
    if lesson.topic?
      comment ? topic_comment_path(lesson, comment) : topic_comments_path(lesson)
    else
      comment ? lesson_comment_path(lesson, comment) : lesson_comments_path(lesson)
    end
  end

  def lesson_target_path(lesson, options = {})
    lesson.topic? ? topic_path(lesson, options) : lesson_path(lesson, options)
  end

  def user_avatar_badge(user, size: :md)
    initial = user&.name.presence&.first&.upcase || "U"

    css = if size == :sm
      if user&.super_admin?
        "w-7 h-7 min-w-[28px] min-h-[28px] max-w-[28px] max-h-[28px] text-xs rounded-full bg-purple-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      elsif user&.admin?
        "w-7 h-7 min-w-[28px] min-h-[28px] max-w-[28px] max-h-[28px] text-xs rounded-full bg-amber-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      else
        "w-7 h-7 min-w-[28px] min-h-[28px] max-w-[28px] max-h-[28px] text-xs rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      end
    else
      if user&.super_admin?
        "w-9 h-9 min-w-[36px] min-h-[36px] max-w-[36px] max-h-[36px] text-sm rounded-full bg-purple-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      elsif user&.admin?
        "w-9 h-9 min-w-[36px] min-h-[36px] max-w-[36px] max-h-[36px] text-sm rounded-full bg-amber-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      else
        "w-9 h-9 min-w-[36px] min-h-[36px] max-w-[36px] max-h-[36px] text-sm rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0"
      end
    end

    tag.div(initial, class: css)
  end

  def user_role_tag(user)
    return unless user

    if user.super_admin?
      tag.span("Super Admin", class: "text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded bg-purple-100 text-purple-800 border border-purple-200")
    elsif user.admin?
      tag.span("Teacher", class: "text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded bg-amber-100 text-amber-800 border border-amber-200")
    else
      tag.span("Student", class: "text-[10px] font-medium px-1.5 py-0.5 rounded bg-stone-100 text-stone-600 border border-stone-200")
    end
  end
end
