ActiveAdmin.register Lesson, as: "Topic" do
  menu priority: 3, label: "Topics"

  permit_params :title, :position, :status, :content, :lesson_type, :lesson_date

  controller do
    def scoped_collection
      end_of_association_chain.topics
    end

    def find_resource
      scoped_collection.find_by(slug: params[:id]) || scoped_collection.find_by(id: params[:id]) || scoped_collection.find(params[:id])
    end

    def new
      build_resource
      resource.lesson_type = :topic
      resource.lesson_date ||= Date.current
      super
    end

    def create
      build_resource
      resource.author = current_user
      resource.lesson_type = :topic
      resource.lesson_date ||= Date.current
      super do |format|
        redirect_to admin_topics_path and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_topics_path and return if resource.valid?
      end
    end
  end

  index do
    selectable_column
    id_column
    column :position
    column :title
    column :status do |topic|
      status_tag topic.status
    end
    column "Completions" do |topic|
      "#{topic.lesson_completions.where(completed: true).count} students"
    end
    actions defaults: true do |topic|
      if topic.draft?
        item "Publish", publish_admin_topic_path(topic), class: "member_link"
      else
        item "Unpublish", unpublish_admin_topic_path(topic), class: "member_link"
      end
      item "Preview", lesson_path(topic), target: "_blank", class: "member_link"
    end
  end

  filter :title
  filter :position
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
    link_to "Publish Topic", publish_admin_topic_path(resource)
  end

  action_item :unpublish, only: :show, if: proc { resource.published? } do
    link_to "Unpublish Topic", unpublish_admin_topic_path(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs "Topic Details (Foundational / Curated English Topics)" do
      f.input :title, placeholder: "e.g. Get Started with English / Must Know Words Before You Start"
      f.input :position, hint: "Order in which students should learn this topic (1, 2, 3...)"
      f.input :status, as: :select, collection: Lesson.statuses.keys
      f.input :content, as: :action_text, hint: "Foundational guide, vocabulary words, and conversational examples"
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :position
      row :status do |topic|
        status_tag topic.status
      end
      row "Completions" do |topic|
        "#{topic.lesson_completions.where(completed: true).count} students"
      end
      row :content do |topic|
        div class: "lesson-rich-text trix-content" do
          topic.content.to_s.html_safe
        end
      end
      row :created_at
      row :updated_at
    end
  end

  member_action :publish, method: %i[get patch] do
    resource.update!(status: :published)
    redirect_back fallback_location: admin_topics_path, notice: "Topic published! Students can now view it."
  end

  member_action :unpublish, method: %i[get patch] do
    resource.update!(status: :draft)
    redirect_back fallback_location: admin_topics_path, notice: "Topic moved back to draft."
  end
end

