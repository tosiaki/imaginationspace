class CreateUserActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :user_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.text :activity_type
      t.text :details

      t.timestamps
    end
  end
end
