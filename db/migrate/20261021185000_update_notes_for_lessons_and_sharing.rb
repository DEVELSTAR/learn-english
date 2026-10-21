class UpdateNotesForLessonsAndSharing < ActiveRecord::Migration[8.0]
  def change
    remove_column :notes, :title, :string
    add_reference :notes, :lesson, foreign_key: true, null: true
    add_column :notes, :is_global, :boolean, default: true, null: false

    create_table :note_shares do |t|
      t.references :note, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :can_edit, default: false, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :note_shares, [:note_id, :user_id], unique: true
    add_index :note_shares, [:user_id, :status]
  end
end

