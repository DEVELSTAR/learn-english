class CreateNoteTypesAndNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :note_types do |t|
      t.string :name, null: false
      t.string :description
      t.string :color, default: "emerald"
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :note_types, :name, unique: true

    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note_type, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
    add_index :notes, %i[note_type_id created_at]
    add_index :notes, %i[user_id created_at]
  end
end

