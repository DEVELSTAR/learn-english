class CreateLessonChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_chat_messages do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :lesson_chat_messages, %i[lesson_id user_id created_at]
  end
end
