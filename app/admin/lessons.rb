ActiveAdmin.register Lesson do
  menu priority: 2, label: "Daily Classes"

  permit_params :title, :lesson_date, :status, :content, :lesson_type, :position

  controller do
    def find_resource
      scoped_collection.find_by(slug: params[:id]) || scoped_collection.find_by(id: params[:id]) || scoped_collection.find(params[:id])
    end

    def new
      build_resource
      resource.lesson_type ||= :daily_class
      resource.lesson_date ||= Date.current
      super
    end

    def create
      build_resource
      resource.author = current_user
      resource.lesson_date ||= Date.current
      super do |format|
        redirect_to admin_lessons_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_lessons_path and return if resource.valid?
      end
    end
  end

  scope("Daily Classes", default: true) { |scope| scope.daily_classes }
  scope("Topics") { |scope| scope.topics }
  scope("All") { |scope| scope }

  index do
    selectable_column
    id_column
    column :title
    column "Type", :lesson_type do |lesson|
      status_tag lesson.lesson_type.humanize, class: (lesson.topic? ? "purple" : "blue")
    end
    column "Class Date", :lesson_date do |lesson|
      lesson.lesson_date.strftime("%B %d, %Y") if lesson.lesson_date
    end
    column :status do |lesson|
      status_tag lesson.status
    end
    column "Completions" do |lesson|
      "#{lesson.lesson_completions.where(completed: true).count} students"
    end
    actions defaults: true do |lesson|
      if lesson.draft?
        item "Publish", publish_admin_lesson_path(lesson), class: "member_link"
      else
        item "Unpublish", unpublish_admin_lesson_path(lesson), class: "member_link"
      end
      item "Preview", lesson_path(lesson), target: "_blank", class: "member_link"
    end
  end

  filter :title
  filter :lesson_type, as: :select, collection: Lesson.lesson_types.keys
  filter :lesson_date
  filter :status, as: :select, collection: proc { Lesson.statuses.keys }

  csv do
    column :id
    column :title
    column :lesson_type
    column :lesson_date
    column :status
    column :position
    column :slug
    column :topic
    column :introduction
    column("Author Name") { |lesson| lesson.author&.name }
    column("Author Email") { |lesson| lesson.author&.email_address }
    column("Content (HTML)") { |lesson| lesson.content&.body&.to_html }
    column("Content (Plain Text)") { |lesson| lesson.content&.body&.to_plain_text }
    column("Completions Count") { |lesson| lesson.lesson_completions.where(completed: true).count }
    column("Comments Count") { |lesson| lesson.lesson_comments.count }
    column :created_at
    column :updated_at
  end

  action_item :publish, only: :show, if: proc { resource.draft? } do
    link_to "Publish Lesson", publish_admin_lesson_path(resource)
  end

  action_item :unpublish, only: :show, if: proc { resource.published? } do
    link_to "Unpublish Lesson", unpublish_admin_lesson_path(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs "Class Details" do
      f.input :lesson_type, as: :select, collection: [["Daily Class (Everyday / Random)", "daily_class"], ["Topic (Foundational / Curated Topic)", "topic"]], include_blank: false
      f.input :title, placeholder: "e.g. Mastering 'Compare' in Everyday English"
      f.input :lesson_date,
              as: :datepicker,
              input_html: {
                type: :date,
                value: (f.object.lesson_date || Date.current).strftime("%Y-%m-%d"),
                style: "width: 180px; max-width: 100%;"
              }
      f.input :position, hint: "Order priority for topics (optional)"
      f.input :status, as: :select, collection: Lesson.statuses.keys
      f.input :content, as: :action_text, hint: "Supports images, bullet points, and Hinglish explanations"
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :lesson_type do |lesson|
        status_tag lesson.lesson_type.humanize
      end
      row :lesson_date do |lesson|
        lesson.lesson_date.strftime("%B %d, %Y") if lesson.lesson_date
      end
      row :position
      row :status do |lesson|
        status_tag lesson.status
      end
      row "Completions" do |lesson|
        "#{lesson.lesson_completions.where(completed: true).count} students"
      end
      row :content do |lesson|
        div class: "lesson-rich-text trix-content" do
          lesson.content.to_s.html_safe
        end
      end
      row :created_at
      row :updated_at
    end
  end

  member_action :publish, method: %i[get patch] do
    resource.update!(status: :published)
    redirect_back fallback_location: admin_lessons_path, notice: "Lesson published! Students can now view it."
  end

  member_action :unpublish, method: %i[get patch] do
    resource.update!(status: :draft)
    redirect_back fallback_location: admin_lessons_path, notice: "Lesson moved back to draft."
  end
end
