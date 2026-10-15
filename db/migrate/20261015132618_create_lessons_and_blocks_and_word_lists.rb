class CreateLessonsAndBlocksAndWordLists < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.date :lesson_date, null: false
      t.string :topic
      t.text :introduction
      t.integer :status, default: 0, null: false
      t.references :author, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :lessons, :slug, unique: true
    add_index :lessons, :lesson_date
    add_index :lessons, :status

    create_table :lesson_blocks do |t|
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }
      t.string :block_type, null: false
      t.json :content, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :lesson_blocks, [:lesson_id, :position]

    create_table :word_lists do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end
    add_index :word_lists, [:user_id, :name], unique: true

    create_table :word_entries do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :word_list, null: false, foreign_key: { on_delete: :cascade }
      t.references :lesson, foreign_key: { on_delete: :nullify }, null: true
      t.string :term, null: false
      t.text :personal_note
      t.integer :status, default: 0, null: false
      t.boolean :needs_revision, default: false, null: false
      t.datetime :last_reviewed_at

      t.timestamps
    end
    add_index :word_entries, [:user_id, :term]
    add_index :word_entries, [:user_id, :status]
    add_index :word_entries, [:user_id, :needs_revision]

    create_table :lesson_completions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :completed, default: false, null: false
      t.boolean :needs_revision, default: false, null: false
      t.datetime :completed_at

      t.timestamps
    end
    add_index :lesson_completions, [:user_id, :lesson_id], unique: true
  end
end
