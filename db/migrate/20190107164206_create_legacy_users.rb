class CreateLegacyUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_users do |t|
      t.references :user, foreign_key: true
      t.text :legacy_username
      t.text :legacy_password_digest

      t.timestamps
    end
  end
end
