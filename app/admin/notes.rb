ActiveAdmin.register Note do
  menu priority: 4, label: "Community Notes"

  actions :index, :show, :destroy

  filter :title
  filter :user, as: :select, collection: proc { User.order(:name).pluck(:name, :id) }
  filter :content
  filter :created_at

  index do
    selectable_column
    id_column
    column "Title", :title do |note|
      link_to note.title, admin_note_path(note), style: "font-weight: bold;"
    end
    column "Author", :user do |note|
      div do
        span note.user&.name, style: "font-weight: bold; margin-right: 6px;"
        status_tag note.user&.role&.humanize
      end
    end
    column "Content", :content do |note|
      truncate(note.content, length: 120)
    end
    column "Created At", :created_at do |note|
      note.created_at.strftime("%b %d, %Y %H:%M")
    end
    actions defaults: true
  end

  show do
    attributes_table do
      row :id
      row :title
      row :user do |note|
        div do
          span note.user&.name, style: "font-weight: bold; margin-right: 6px;"
          span "(#{note.user&.email_address})", style: "color: #777;"
          status_tag note.user&.role&.humanize
        end
      end
      row :content do |note|
        simple_format note.content
      end
      row :created_at
      row :updated_at
    end
  end
end
