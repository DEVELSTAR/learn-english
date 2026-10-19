class UpdateNotesSchema < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :title, :string, default: "Untitled Note"
    change_column_default :notes, :title, nil

    if foreign_key_exists?(:notes, :note_types)
      remove_foreign_key :notes, :note_types
    end

    if column_exists?(:notes, :note_type_id)
      remove_index :notes, %i[note_type_id created_at] if index_exists?(:notes, %i[note_type_id created_at])
      remove_column :notes, :note_type_id, :integer
    end

    drop_table :note_types, if_exists: true
  end
end

