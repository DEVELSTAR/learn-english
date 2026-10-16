class AddLessonTypeAndPositionToLessons < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :lesson_type, :integer, default: 0, null: false
    add_column :lessons, :position, :integer, default: 0, null: false
    add_index :lessons, :lesson_type
    add_index :lessons, :position
  end
end
