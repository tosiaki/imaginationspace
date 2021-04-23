class CreateStartupStates < ActiveRecord::Migration[6.1]
  def change
    create_table :startup_states do |t|
      t.text :environment
      t.bigint :guild_id
      t.datetime :last_checked

      t.timestamps
    end
  end
end
