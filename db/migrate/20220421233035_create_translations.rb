class CreateTranslations < ActiveRecord::Migration[6.1]
  def change
    create_table :translations do |t|
      t.text :title

      t.timestamps
    end
  end
end
