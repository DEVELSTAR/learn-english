ActiveAdmin.register WordList, as: "Shared Word List" do
  menu priority: 4, label: "Shared Word Lists"

  permit_params :name, :initial_words

  controller do
    def scoped_collection
      WordList.created_by_admin
    end

    def create
      initial_words = params[:word_list][:initial_words]
      build_resource
      resource.user = current_user
      resource.is_default = false
      if resource.save
        count = resource.add_words_from_text(initial_words, user: current_user)
        suffix = count.positive? ? " with #{count} #{'word'.pluralize(count)}" : ""
        redirect_to admin_shared_word_list_path(resource), notice: "Shared List '#{resource.name}' created#{suffix}."
      else
        render :new
      end
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
      f.input :initial_words, as: :text, label: "Add Words to List (Optional)",
              hint: "Paste multiple words at once (one per line). Format: 'word: meaning' or just 'word'. Example:\nafford: have enough money to buy\ncompare: evaluate differences",
              input_html: { rows: 8, placeholder: "afford: have enough money to buy\ncompare: evaluate differences\ntake for granted: fail to properly appreciate" }
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

    panel "Add Words to this Shared List" do
      active_admin_form_for WordEntry.new(word_list: shared_word_list), url: add_entry_admin_shared_word_list_path(shared_word_list), method: :post do |f|
        f.inputs do
          f.input :term, label: "Single Word / Term (or leave blank if pasting multiple below)"
          f.input :personal_note, label: "Meaning & Context for Single Word"
          f.input :bulk_words, as: :text, label: "OR Paste Multiple Words in Bulk (one per line)",
                  hint: "Format: 'word: meaning' or just 'word'. Example:\nafford: can pay for\ncompare: evaluate differences",
                  input_html: { rows: 5, placeholder: "afford: can pay for\ncompare: evaluate differences\ntake for granted: fail to appreciate" }
        end
        f.actions do
          f.action :submit, label: "+ Add Word(s) to List"
        end
      end
    end
  end

  member_action :add_entry, method: :post do
    bulk = params.dig(:word_entry, :bulk_words)
    count = 0
    if bulk.present?
      count += resource.add_words_from_text(bulk, user: current_user)
    end

    term = params.dig(:word_entry, :term).to_s.strip
    if term.present?
      entry = resource.word_entries.find_or_initialize_by(term: term)
      entry.user = current_user
      entry.personal_note = params.dig(:word_entry, :personal_note)
      count += 1 if entry.save
    end

    if count > 0
      redirect_to admin_shared_word_list_path(resource), notice: "#{count} #{'word'.pluralize(count)} added to #{resource.name}."
    else
      redirect_to admin_shared_word_list_path(resource), alert: "Please provide a word or paste multiple words."
    end
  end

  member_action :remove_entry, method: :delete do
    entry = resource.word_entries.find(params[:entry_id])
    term = entry.term
    entry.destroy!
    redirect_to admin_shared_word_list_path(resource), notice: "Word '#{term}' removed from #{resource.name}."
  end
end
