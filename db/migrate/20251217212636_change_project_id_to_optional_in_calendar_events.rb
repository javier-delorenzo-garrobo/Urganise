class ChangeProjectIdToOptionalInCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :calendar_events, :project_id, true
    change_column_null :notes, :project_id, true
  end
end
