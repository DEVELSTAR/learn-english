ActiveAdmin.register WordList, as: "Shared Word List" do
  menu priority: 4, label: "Shared Word Lists"

  permit_params :name

  controller do
    def scoped_collection
      WordList.created_by_admin
    end

    def create
      build_resource
      resource.user = current_user
      resource.is_default = false
      super
    end

    def update
      super do |format|
        redirect_to admin_shared_word_lists_path, notice: "Shared List '#{resource.name}' updated." and return if resource.valid?
      end
    end

    def destroy
      super do |format|
        redirect_to admin_shared_word_lists_path, notice: "Shared List deleted." and return
      end
    end
  end

  index do
    selectable_column
    id_column
    column "List Name", :name
    column "Words Count" do |list|
      "#{list.word_entries.count} words"
    end
    column "Visibility" do
      status_tag "Shared with all students", class: "ok"
    end
    column "Created Date", :created_at do |list|
      list.created_at.strftime("%B %d, %Y")
    end
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.semantic_errors
    f.inputs "Shared Word List Details" do
      f.input :name, placeholder: "e.g. Essential Workplace English, Phrasal Verbs"
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row "Visibility" do
        status_tag "Shared to all students", class: "ok"
      end
      row "Total Words" do |list|
        list.word_entries.count
      end
      row :created_at
      row :updated_at
    end

    panel "Words in this Shared List (#{shared_word_list.word_entries.count})" do
      entries = shared_word_list.word_entries.recent
      if entries.any?
        table_for entries do
          column("Word / Term") { |e| strong e.term }
          column("Meaning & Context") { |e| e.personal_note.presence || "-" }
          column("Added On") { |e| e.created_at.strftime("%B %d, %Y") }
          column("Action") do |e|
            link_to "Remove Word", remove_entry_admin_shared_word_list_path(shared_word_list, entry_id: e.id), method: :delete, data: { confirm: "Remove '#{e.term}' from this list?" }, class: "member_link"
          end
        end
      else
        div class: "blank_slate_container" do
          span "No words added to this shared list yet."
        end
      end
    end

    panel "Add Word to this Shared List" do
      active_admin_form_for WordEntry.new(word_list: shared_word_list), url: add_entry_admin_shared_word_list_path(shared_word_list), method: :post do |f|
        f.inputs do
          f.input :term, label: "Word / Term"
          f.input :personal_note, label: "Meaning & Context"
        end
        f.actions do
          f.action :submit, label: "+ Add Word to List"
        end
      end
    end
  end

  member_action :add_entry, method: :post do
    entry = resource.word_entries.build(params.require(:word_entry).permit(:term, :personal_note))
    entry.user = current_user

    if entry.save
      redirect_to admin_shared_word_list_path(resource), notice: "Word '#{entry.term}' added to #{resource.name}."
    else
      redirect_to admin_shared_word_list_path(resource), alert: entry.errors.full_messages.join(", ")
    end
  end

  member_action :remove_entry, method: :delete do
    entry = resource.word_entries.find(params[:entry_id])
    term = entry.term
    entry.destroy!
    redirect_to admin_shared_word_list_path(resource), notice: "Word '#{term}' removed from #{resource.name}."
  end
end
