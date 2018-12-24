class AddTimelineTimeToStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :timeline_time, :datetime
  end
end
