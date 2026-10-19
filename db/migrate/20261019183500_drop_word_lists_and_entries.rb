class DropWordListsAndEntries < ActiveRecord::Migration[8.0]
  def change
    drop_table :word_list_chat_messages, if_exists: true
    drop_table :word_entries, if_exists: true
    drop_table :word_lists, if_exists: true
  end
end

