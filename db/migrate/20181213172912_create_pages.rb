class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.references :article, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
