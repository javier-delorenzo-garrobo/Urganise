class CreateAiSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_suggestions do |t|
      t.integer :suggestion_type, null: false
      t.text :content, null: false
      t.jsonb :metadata, default: {}
      t.references :user, null: false, foreign_key: true
      t.references :task, null: true, foreign_key: true

      t.timestamps
    end

    add_index :ai_suggestions, [:user_id, :created_at]
    add_index :ai_suggestions, :suggestion_type
  end
end
