class CreateWordListChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :word_list_chat_messages do |t|
      t.references :word_list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false

      t.timestamps
    end
    add_index :word_list_chat_messages, [ :word_list_id, :user_id, :created_at ]
  end
end
