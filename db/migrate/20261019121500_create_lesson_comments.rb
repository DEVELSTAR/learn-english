class CreateLessonComments < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_comments do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :lesson_comments }
      t.text :content, null: false

      t.timestamps
    end

    add_index :lesson_comments, %i[lesson_id created_at]
  end
end

