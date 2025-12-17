class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :color, default: "#3B82F6"
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :categories, [:project_id, :name], unique: true
  end
end
