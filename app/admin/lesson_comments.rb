ActiveAdmin.register LessonComment do
  menu priority: 6, label: "Comments & Chat"

  actions :index, :show, :destroy

  filter :lesson, as: :select, collection: proc { Lesson.order(:title).pluck(:title, :id) }
  filter :user, as: :select, collection: proc { User.order(:name).pluck(:name, :id) }
  filter :created_at

  index do
    selectable_column
    id_column
    column "Lesson / Topic", :lesson do |comment|
      link_to comment.lesson.title, admin_lesson_path(comment.lesson)
    end
    column "Author", :user do |comment|
      div do
        span comment.user.name, style: "font-weight: bold; margin-right: 6px;"
        status_tag comment.user.role.humanize, class: (comment.user.admin? ? "orange" : "green")
      end
    end
    column "Content", :content do |comment|
      truncate(comment.content, length: 80)
    end
    column "Thread", :parent do |comment|
      if comment.reply?
        status_tag "Reply", class: "purple"
      else
        status_tag "Root", class: "blue"
      end
    end
    column "Created At", :created_at do |comment|
      comment.created_at.strftime("%b %d, %Y %H:%M")
    end
    actions defaults: true
  end

  show do
    attributes_table do
      row :id
      row :lesson do |comment|
        link_to comment.lesson.title, admin_lesson_path(comment.lesson)
      end
      row :user do |comment|
        div do
          span comment.user.name, style: "font-weight: bold; margin-right: 6px;"
          span "(#{comment.user.email_address})", style: "color: #777; margin-right: 6px;"
          status_tag comment.user.role.humanize
        end
      end
      row :parent do |comment|
        if comment.parent
          link_to "Parent Comment ##{comment.parent.id} by #{comment.parent.user&.name}", admin_lesson_comment_path(comment.parent)
        else
          span "Root Discussion Thread", style: "color: #777;"
        end
      end
      row :content do |comment|
        simple_format comment.content
      end
      row :created_at
      row :updated_at
    end

    if resource.root? && resource.replies.any?
      panel "Replies to this comment (#{resource.replies.count})" do
        table_for resource.replies.order(created_at: :asc) do
          column("Author") { |r| "#{r.user&.name} (#{r.user&.role})" }
          column("Content") { |r| truncate(r.content, length: 120) }
          column("Date") { |r| r.created_at.strftime("%b %d, %Y %H:%M") }
          column("Actions") do |r|
            link_to "View", admin_lesson_comment_path(r), class: "member_link"
          end
        end
      end
    end
  end
end

