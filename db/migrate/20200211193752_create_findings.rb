class CreateFindings < ActiveRecord::Migration[5.2]
  def change
    create_table :findings do |t|
      t.text :thing_name
      t.integer :required_experience
			t.float :scarcity

      t.timestamps
    end
  end
end
