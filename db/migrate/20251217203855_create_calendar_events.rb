class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :all_day
      t.string :event_type
      t.string :color
      t.string :location
      t.jsonb :attendees
      t.integer :reminder_minutes
      t.string :recurrence_rule

      t.timestamps
    end
  end
end
