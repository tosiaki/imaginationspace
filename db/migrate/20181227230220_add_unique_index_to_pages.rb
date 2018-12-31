class AddUniqueIndexToPages < ActiveRecord::Migration[5.2]
  def change
    add_index :pages, [:article_id, :page_number], unique: true, name: 'page_number_index'
  end
end
