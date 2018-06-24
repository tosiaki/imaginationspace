class CreateKudos < ActiveRecord::Migration[5.2]
  def change
    create_table :kudos do |t|
      t.references :user
      t.references :work, polymorphic: true, index: true
      t.string :ip_address

      t.timestamps
    end
  end
end
