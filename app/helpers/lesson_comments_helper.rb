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
    dimensions = size == :sm ? "w-7 h-7 text-xs" : "w-9 h-9 text-sm"

    bg_class = if user&.super_admin?
                 "bg-purple-600 text-white"
               elsif user&.admin?
                 "bg-amber-600 text-white"
               else
                 "bg-emerald-600 text-white"
               end

    tag.div(initial, class: "#{dimensions} rounded-full #{bg_class} flex items-center justify-center font-bold font-mono select-none shadow-xs shrink-0")
  end

  def user_role_tag(user)
    return unless user

    if user.super_admin?
      tag.span("Super Admin", class: "text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded bg-purple-100 text-purple-800 border border-purple-200")
    elsif user.admin?
      tag.span("Teacher", class: "text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded bg-amber-100 text-amber-800 border border-amber-200")
    else
      tag.span("Student", class: "text-[10px] font-medium px-1.5 py-0.5 rounded bg-stone-100 text-stone-600")
    end
  end
end

