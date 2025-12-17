class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.string :color
      t.jsonb :tags
      t.jsonb :attachments

      t.timestamps
    end
  end
end
