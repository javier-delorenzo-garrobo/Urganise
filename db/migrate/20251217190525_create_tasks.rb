class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.date :due_date
      t.datetime :completed_at
      t.references :project, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tasks, [:user_id, :status]
    add_index :tasks, [:project_id, :status]
    add_index :tasks, :due_date
  end
end
